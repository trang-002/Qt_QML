#ifndef TASKMODEL_H
#define TASKMODEL_H

#include <QAbstractListModel>
#include <QString>
#include <QVector>

class TaskModel : public QAbstractListModel
{
    Q_OBJECT

    // ===== Counter footer =====
        Q_PROPERTY(int doneCount READ doneCount NOTIFY countChanged)
        Q_PROPERTY(int totalCount READ totalCount NOTIFY countChanged)

public:
    explicit TaskModel(QObject *parent = nullptr);

    enum TaskRoles {
        NameRole = Qt::UserRole + 1,
        DoneRole
    };

    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    // ===== API cho QML =====
        Q_INVOKABLE void addTask(const QString &name);
        Q_INVOKABLE void setDone(int index, bool done);
        Q_INVOKABLE void deleteTask(int index);

    // Counter
        int doneCount() const;
        int totalCount() const;
signals:
    void countChanged();

protected:
    QHash<int, QByteArray> roleNames() const override;

private:
    struct Task {
        QString name;
        bool done;
    };

    QVector<Task> m_tasks;
};

#endif
