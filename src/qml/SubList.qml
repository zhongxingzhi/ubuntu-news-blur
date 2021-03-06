/*
    A News Blur client for Ubuntu Phone
    Copyright (C) 2013  Jimi Smith <smithj002@gmail.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import QtQuick 2.0
import NewsBlur 0.1
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem

Page {
    id: feedPage
    signal itemClicked(var subscription)
    property bool isUpdating: false

    FeedModel {
        id: feedModel
        Component.onCompleted: {
            feedModel.refresh();
        }
    }

    Connections {
        target: readerView
        onRefresh: {
            var resp = api.getFeeds();
            resp.responseReceived.connect(function () {
                feedPage.isUpdating = false;
                feedModel.refresh();
                if (feedModel.needsUpdatedCounts()) {
                    var unreadResp = api.updateUnreadCount();
                    unreadResp.responseReceived.connect(function () {
                        feedModel.refresh();
                    });
                }
            });
            feedPage.isUpdating = true;
        }
    }

    Tabs {
        id: tabs
        anchors.fill: parent

        Tab {
            objectName: "AllTab"
            title: i18n.tr("All")
            page: Page {

                ListView {
                    id: allFeedList
                    anchors.fill: parent
                    model: FilteredFeedModel {
                        id: allFeedModel
                        filter: "all"
                        sourceModel: feedModel
                    }

                    delegate: SubItem {
                        itemTitle: title
                        unreadCount: unread
                        updating: feedPage.isUpdating || needs_update
                        onClicked: {
                            itemClicked(id, title);
                        }
                    }
                }
            }
        }

        Tab {
            objectName: "UnreadTab"
            title: i18n.tr("Unread")
            page: Page {

                ListView {
                    id: unreadFeedList
                    anchors.fill: parent
                    model: FilteredFeedModel {
                        id: unreadFeedModel
                        filter: "unread"
                        sourceModel: feedModel
                    }

                    delegate: SubItem {
                        itemTitle: title
                        unreadCount: unread
                        updating: feedPage.isUpdating || needs_update
                        onClicked: {
                            itemClicked(id, title);
                        }
                    }
                }
            }
        }
    }
}
