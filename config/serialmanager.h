#pragma once
#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QMap>
#include <QTimer>
#include <QVariant>
#include <QQueue>
#include <QString>
#include <QByteArray>

class SerialManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool connected READ isConnected NOTIFY connectionChanged)

public:
    explicit SerialManager(QObject *parent = nullptr);

    struct PendingParam
    {
        int sys;
        int comp;
        int msg;
        QString value;
    };

    Q_INVOKABLE QStringList getAvailablePorts();
    Q_INVOKABLE bool openPort(QString name, int baud);
    Q_INVOKABLE void loadParameters();
    Q_INVOKABLE void closePort();
    Q_INVOKABLE void setParam(int sys, int comp, int msg, QString value);
    Q_INVOKABLE void applyParams(QVariantList params);
    Q_INVOKABLE void sendNextParam();
    Q_INVOKABLE void saveFlash();

    bool isConnected() const;
    void sendCommand(const QString &cmd);

signals:
    void connectionChanged();
    void paramUpdated(QString name, QString value);
    void paramReceived(int sys,
                       int comp,
                       int msg,
                       QString name, QString value);
    void listFinished();

    void paramApplied(int sys,int comp,int msg);
    void paramError(int sys,int comp,int msg,QString reason);
    void applyFinished();

private:
    QSerialPort serial;
    QByteArray buffer;
    QMap<QString, QString> params;
    bool m_connected = false;

    QQueue<PendingParam> pendingQueue;

    void parseLine(const QString &line);


private slots:
    void readData();
};
