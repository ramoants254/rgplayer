#pragma once

#include <QAbstractListModel>
#include <QStringList>

class PlaylistModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int currentIndex READ currentIndex NOTIFY currentIndexChanged)

public:
    enum Role {
        PathRole = Qt::UserRole + 1,
        TitleRole,
    };

    explicit PlaylistModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = {}) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int currentIndex() const;

    Q_INVOKABLE void addFile(const QString &path);
    Q_INVOKABLE void removeAt(int index);
    Q_INVOKABLE void clear();
    Q_INVOKABLE void playAt(int index);
    Q_INVOKABLE void playNext();
    Q_INVOKABLE void playPrevious();
    Q_INVOKABLE int count() const;
    Q_INVOKABLE QString getPath(int index) const;

signals:
    void currentIndexChanged();
    void playRequested(const QString &path);

private:
    void save() const;

    QStringList paths_;
    int currentIndex_ = -1;
};
