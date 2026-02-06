#include "taskmodel.h"
#include <QDebug>


TaskModel::TaskModel(QObject *parent)
    : QAbstractListModel(parent)
{
    // ===== dữ liệu giả =====
    m_tasks.append({ "Learn Qt", true });
    m_tasks.append({ "Learn QML", true });
    m_tasks.append({ "Build Todo App", false });

}

int TaskModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return m_tasks.size();

}


QVariant TaskModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    const Task &task = m_tasks.at(index.row());

    switch (role) {
    case NameRole:
        return task.name;
    case DoneRole:
        return task.done;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> TaskModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[NameRole] = "name";
    roles[DoneRole] = "done";
    return roles;
}

// ===== THÊM TASK =====
void TaskModel::addTask(const QString &name)
{
    if (name.trimmed().isEmpty())
        return;

    const int newIndex = m_tasks.size();

    beginInsertRows(QModelIndex(), newIndex, newIndex);
    m_tasks.append({ name, false });
    endInsertRows();
    emit countChanged();

    qDebug() << "Added task:" << name;
}

void TaskModel::setDone(int index, bool done)
{
    if (index < 0 || index >= m_tasks.size())
        return;

    if (m_tasks[index].done == done)
        return;

    m_tasks[index].done = done;

    QModelIndex modelIndex = createIndex(index, 0);
    emit dataChanged(modelIndex, modelIndex, { DoneRole });
    emit countChanged();

    qDebug() << "Task" << index << "set done =" << done;
}

void TaskModel::deleteTask(int index)
{
    if (index < 0 || index >= m_tasks.size())
        return;

    beginRemoveRows(QModelIndex(), index, index);
    m_tasks.removeAt(index);
    endRemoveRows();

    emit countChanged();
}
// ===== Count done =====
int TaskModel::doneCount() const
{
    int count = 0;
    for (const auto &t : m_tasks)
        if (t.done) count++;
    return count;
}

int TaskModel::totalCount() const
{
    return m_tasks.size();
}


