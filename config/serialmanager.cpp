#include "serialmanager.h"
#include <QDebug>
#include <QRegularExpression>

SerialManager::SerialManager(QObject *parent)
    : QObject(parent)
{
    connect(&serial, &QSerialPort::readyRead,
            this, &SerialManager::readData);
}

QStringList SerialManager::getAvailablePorts()
{
    QStringList list;
    const auto ports = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &port : ports)
        list << port.portName();
    return list;
}

bool SerialManager::openPort(QString name, int baud)
{
    serial.setPortName(name);
    serial.setBaudRate(baud);

        serial.setDataBits(QSerialPort::Data8);
        serial.setParity(QSerialPort::NoParity);
        serial.setStopBits(QSerialPort::OneStop);
        serial.setFlowControl(QSerialPort::NoFlowControl);

    if (serial.open(QIODevice::ReadWrite)) {
        qDebug() << "Port opened:" << name;
        m_connected = true;
        emit connectionChanged();
//        sendCommand("LIST\r\n");

        return true;
    }
    qDebug() << "Open error:" << serial.errorString();
    return false;
}

// ========================================================================
void SerialManager::loadParameters()
{
    if(!serial.isOpen())
        return;

    buffer.clear();

    qDebug() << "Request LIST";

    serial.write("LIST\r\n");
}


void SerialManager::closePort()
{
    if (serial.isOpen())
        serial.close();

    m_connected = false;
    emit connectionChanged();
}

void SerialManager::sendCommand(const QString &cmd)
{
    if(serial.isOpen())
        serial.write(cmd.toUtf8());
}

bool SerialManager::isConnected() const
{
    return m_connected;
}

void SerialManager::readData()
{
    buffer += serial.readAll();

    while(buffer.contains("\n"))
    {
        int idx = buffer.indexOf("\n");

        QString line = buffer.left(idx).trimmed();
        buffer.remove(0, idx + 1);
        if(line.isEmpty())
                continue;

        qDebug() << "UART:" << line; // <=============================

        parseLine(line);
    }
}


void SerialManager::parseLine(const QString &line)
{
    static QRegularExpression rx(
        "\\[(.*?)\\s+(\\d+)-(\\d+)-(\\d+)\\]\\s+(.*?)\\s+=\\s+(.*)"
    );

    auto match = rx.match(line);

    if(match.hasMatch())
    {
        int sys  = match.captured(2).toInt();
        int comp = match.captured(3).toInt();
        int msg  = match.captured(4).toInt();

        QString name  = match.captured(5);
        QString value = match.captured(6);

        qDebug() << "Parsed:" << sys << comp << msg << name << value;

        emit paramReceived(sys, comp, msg, name, value);
        return;
    }

    if(pendingQueue.isEmpty())
        return;

    PendingParam p = pendingQueue.head();

    if(line.startsWith("OK"))
    {
        pendingQueue.dequeue();
        emit paramApplied(p.sys,p.comp,p.msg);
    }
    else if(line.startsWith("ERR"))
    {
        pendingQueue.dequeue();
        qDebug() << "Emit paramError";
        emit paramError(p.sys,p.comp,p.msg,line);
    }

    QTimer::singleShot(30,this,&SerialManager::sendNextParam);
}

void SerialManager::setParam(int sys, int comp, int msg, QString value)
{
    if(!serial.isOpen())
        return;

    QString cmd = QString("FE %1 %2 %3 %4\r\n")
            .arg(sys)
            .arg(comp)
            .arg(msg)
            .arg(value);

    qDebug() << "SEND:" << cmd;

    serial.write(cmd.toUtf8());
}

void SerialManager::saveFlash()
{
    if(!serial.isOpen())
        return;
    serial.write("SAVE\r\n");
}

void SerialManager::applyParams(QVariantList params)
{
    pendingQueue.clear();

    for(auto &p : params)
    {
        QVariantMap m = p.toMap();

        PendingParam item;
        item.sys  = m["sys"].toInt();
        item.comp = m["comp"].toInt();
        item.msg  = m["msg"].toInt();
        item.value = m["value"].toString();

        pendingQueue.enqueue(item);
    }

    sendNextParam();
}

void SerialManager::sendNextParam()
{
    if(pendingQueue.isEmpty())
    {
        emit applyFinished();
        return;
    }

    PendingParam p = pendingQueue.head();

    QString cmd = QString("FE %1 %2 %3 %4\r\n")
            .arg(p.sys)
            .arg(p.comp)
            .arg(p.msg)
            .arg(p.value);

    qDebug() << "SEND:" << cmd;

    serial.write(cmd.toUtf8());
}
