#include "playlist_model.h"

#include <QDir>
#include <QFileInfo>
#include <QSettings>

PlaylistModel::PlaylistModel(QObject *parent)
    : QAbstractListModel(parent)
{
    const QStringList saved = QSettings().value(QStringLiteral("playlist/paths")).toStringList();
    for (const QString &p : saved) {
        if (!p.startsWith(QLatin1Char('-')) && QFileInfo::exists(p)) {
            paths_.append(p);
        }
    }
    if (paths_.size() != saved.size()) {
        save();
    }
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
    QFileInfo info(path);
    if (!info.exists()) {
        return;
    }

    if (info.isDir()) {
        QDir dir(path);
        const QStringList nameFilters = {
            QStringLiteral("*.mp4"), QStringLiteral("*.mkv"), QStringLiteral("*.webm"),
            QStringLiteral("*.avi"), QStringLiteral("*.mov"), QStringLiteral("*.ts"),
            QStringLiteral("*.flv"), QStringLiteral("*.m4v"), QStringLiteral("*.wmv"),
            QStringLiteral("*.mp3"), QStringLiteral("*.flac"), QStringLiteral("*.wav"),
            QStringLiteral("*.m4a"), QStringLiteral("*.aac"), QStringLiteral("*.ogg"),
            QStringLiteral("*.opus"), QStringLiteral("*.wma")
        };
        const QFileInfoList entries = dir.entryInfoList(nameFilters, QDir::Files, QDir::Name);
        for (const QFileInfo &entry : entries) {
            addFile(entry.absoluteFilePath());
        }
        return;
    }

    const QString normalizedPath = info.absoluteFilePath();
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

void PlaylistModel::move(int from, int to)
{
    if (from < 0 || from >= paths_.size() || to < 0 || to >= paths_.size() || from == to) {
        return;
    }

    const int destination = to > from ? to + 1 : to;
    if (!beginMoveRows({}, from, from, {}, destination)) {
        return;
    }

    paths_.move(from, to);
    endMoveRows();

    if (currentIndex_ == from) {
        currentIndex_ = to;
        emit currentIndexChanged();
    } else if (from < currentIndex_ && to >= currentIndex_) {
        --currentIndex_;
        emit currentIndexChanged();
    } else if (from > currentIndex_ && to <= currentIndex_) {
        ++currentIndex_;
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

void PlaylistModel::playNext()
{
    if (paths_.isEmpty()) {
        return;
    }
    const int nextIndex = (currentIndex_ + 1 < paths_.size()) ? currentIndex_ + 1 : 0;
    playAt(nextIndex);
}

void PlaylistModel::playPrevious()
{
    if (paths_.isEmpty()) {
        return;
    }
    const int prevIndex = (currentIndex_ - 1 >= 0) ? currentIndex_ - 1 : paths_.size() - 1;
    playAt(prevIndex);
}

void PlaylistModel::save() const
{
    QSettings settings;
    settings.setValue(QStringLiteral("playlist/paths"), paths_);
}

int PlaylistModel::count() const
{
    return paths_.size();
}

QString PlaylistModel::getPath(int index) const
{
    return (index >= 0 && index < paths_.size()) ? paths_.at(index) : QString();
}
