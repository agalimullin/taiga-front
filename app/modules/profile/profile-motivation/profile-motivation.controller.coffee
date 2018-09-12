###
# Copyright (C) 2014-2017 Taiga Agile LLC <taiga@taiga.io>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#
# File: profile-contacts.controller.coffee
###

class ProfileMotivationController
    @.$inject = [
        "tgUserService",
        "tgCurrentUserService",
        "tgProjectsService",
        "$scope",
    ]

    constructor: (@userService, @currentUserService, @projectsService, @scope) ->
        @.currentUser = @currentUserService.getUser()
        @projectsService.getProjectsByUserId(@.currentUser.get("id")).then (projects) =>
            @.userProjects = projects.toJS()

        @.currentDate = new Date();

        @.isCurrentUser = false

        if @.currentUser && @.currentUser.get("id") == @.user.get("id")
            @.isCurrentUser = true

        @.loadStats()


    loadStats: () ->
        return @userService.getStats(@.user.get("id")).then (stats) =>
            @.stats = stats.toJS()

    isUserActiveInProjects: () ->
        if @.stats["projects_activity"] == null
            return 0
        else
            Object.keys(@.stats["projects_activity"]).length

    getActivityProjectsLength: () ->
        Object.keys(@.stats["projects_activity"]).length


angular.module("taigaProfile")
    .controller("ProfileMotivation", ProfileMotivationController)
