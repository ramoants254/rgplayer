#include "playlist_model.h"

#include <QFileInfo>
#include <QSettings>

PlaylistModel::PlaylistModel(QObject *parent)
    : QAbstractListModel(parent)
    , paths_(QSettings().value(QStringLiteral("playlist/paths")).toStringList())
{
}

int PlaylistModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : paths_.size();
}

QVariant PlaylistModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= paths_.size()) {
        return {};
    }

    const QString &path = paths_.at(index.row());
    if (role == PathRole) {
        return path;
    }
    if (role == TitleRole || role == Qt::DisplayRole) {
        return QFileInfo(path).fileName();
    }
    return {};
}

QHash<int, QByteArray> PlaylistModel::roleNames() const
{
    return {{PathRole, "path"}, {TitleRole, "title"}};
}

int PlaylistModel::currentIndex() const
{
    return currentIndex_;
}

void PlaylistModel::addFile(const QString &path)
{
    const QString normalizedPath = QFileInfo(path).absoluteFilePath();
    if (normalizedPath.isEmpty() || paths_.contains(normalizedPath)) {
        return;
    }

    const int row = paths_.size();
    beginInsertRows({}, row, row);
    paths_.append(normalizedPath);
    endInsertRows();
    save();
}

void PlaylistModel::removeAt(int index)
{
    if (index < 0 || index >= paths_.size()) {
        return;
    }

    beginRemoveRows({}, index, index);
    paths_.removeAt(index);
    endRemoveRows();
    if (currentIndex_ == index) {
        currentIndex_ = -1;
        emit currentIndexChanged();
    } else if (currentIndex_ > index) {
        --currentIndex_;
        emit currentIndexChanged();
    }
    save();
}

void PlaylistModel::clear()
{
    if (paths_.isEmpty()) {
        return;
    }

    beginResetModel();
    paths_.clear();
    currentIndex_ = -1;
    endResetModel();
    emit currentIndexChanged();
    save();
}

void PlaylistModel::playAt(int index)
{
    if (index < 0 || index >= paths_.size()) {
        return;
    }

    currentIndex_ = index;
    emit currentIndexChanged();
    emit playRequested(paths_.at(index));
}

void PlaylistModel::save() const
{
    QSettings settings;
    settings.setValue(QStringLiteral("playlist/paths"), paths_);
}
