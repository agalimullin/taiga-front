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
# File: project.controller.coffee
###

generateHash = @.taiga.generateHash
groupBy = @.taiga.groupBy


class ProjectController
    @.$inject = [
        "$scope",
        "$rootScope",
        "$routeParams",
        "tgAppMetaService",
        "$tgAuth",
        "$translate",
        "tgProjectService",
        "$tgResources"
    ]

    constructor: (@scope, @rootscope, @routeParams, @appMetaService, @auth, @translate, @projectService, @rs) ->
        @.user = @auth.userData

        taiga.defineImmutableProperty @, "project", () => return @projectService.project
        taiga.defineImmutableProperty @, "members", () => return @projectService.activeMembers

        @appMetaService.setfn @._setMeta.bind(this)


        @.milestonesOrder = {}
        @scope.showGantGraphPlaceholder = null

        promise = @.loadSprints()

        # On Success
        promise.then =>
            @scope.showGanttGraphPlaceholder = !@scope.sprints?

    loadSprints: ->
        params = {closed: false}
        return @rs.sprints.list(@.project.get("id"), params).then (result) =>
            sprints = result.milestones

            @.setMilestonesOrder(sprints)

            @scope.totalMilestones = sprints
            @scope.totalClosedMilestones = result.closed
            @scope.totalOpenMilestones = result.open
            @scope.totalMilestones = @scope.totalOpenMilestones + @scope.totalClosedMilestones

            # NOTE: Fix order of USs because the filter orderBy does not work propertly in partials files
            for sprint in sprints
              sprint.user_stories = _.sortBy(sprint.user_stories, "sprint_order")

            @scope.sprints = sprints

            @scope.closedSprints =  [] if !@scope.closedSprints

            @scope.sprintsCounter = sprints.length
            @scope.sprintsById = groupBy(sprints, (x) -> x.id)

            @rootscope.$broadcast("sprints:loaded", @scope.sprints)

            return sprints

    setMilestonesOrder: (sprints) ->
        for sprint in sprints
            @.milestonesOrder[sprint.id] = {}
            for it in sprint.user_stories
                @.milestonesOrder[sprint.id][it.id] = it.sprint_order

    _setMeta: ()->
        return null if !@.project

        ctx = {projectName: @.project.get("name")}

        return {
            title: @translate.instant("PROJECT.PAGE_TITLE", ctx)
            description: @.project.get("description")
        }

angular.module("taigaProjects").controller("Project", ProjectController)

##############################################################################
### Gantt graph directive
##############################################################################
ToggleGanttVisibility = ($storage, $rootScope, $timeout, $ctrl) ->
    hide = () ->
        $('.js-gantt-graph').slideUp("normal", ->
          return
        )
        $(".gantt-button").removeClass('active')

    show = (firstLoad) ->
        $(".gantt-button").addClass('active')
        $('.js-gantt-graph').slideDown("normal", ->
          return
        )
        if firstLoad
            $timeout (->
                $(".gantt-side").width("700px")
                return
            ), 0
            $(".js-gantt-graph").addClass("shown")
        else
            $(".js-gantt-graph").addClass("open")

    link = ($scope, $el, $attrs, $ctrl) ->
        firstLoad = true
        hash = generateHash(["is-gantt-graphs-collapsed"])
        $scope.isGanttGraphCollapsed = $storage.get(hash) or false

        $scope.data = []

        $scope.$on("sprints:loaded", () ->
          if $scope.sprints != undefined
            for spr,i in $scope.sprints.reverse()
              $scope.data.push {
                  title: spr.name
                  assignetTo: 'assignedTo'
                  daysTotal: 'days'
                  storyPoints: 'storyPoints'
                  status: 'status'
                  height: '3em'
                  sortable: false
                  classes: 'gantt-row-milestone '
                  color: '#b1e1cd'
                  tasks: [
                    {
                      title: ''
                      color: '#b1e1cd'
                      from: spr.estimated_start
                      to: spr.estimated_finish
                      classes: 'gantt-cell-milestone'
                      data: ''
                    }
                  ]
                  data: 'Can contain any custom data or object'
              }
              start = new Date(spr.estimated_start)
              end = new Date(spr.estimated_finish)
              timeDiff = Math.abs(end.getTime() - start.getTime())
              diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24))

              avgHoursPerStory = if spr.user_stories.length > 0 then diffDays / spr.user_stories.length else diffDays

              for us, i in spr.user_stories
                $scope.data.push {
                      id: us.id
                      title: if us.subject.length > 21 then us.subject.substring(0,21)+'...' else us.subject
                      assignetTo: if us.assigned_to_extra_info then us.assigned_to_extra_info.full_name_display else ''
                      daysTotal: avgHoursPerStory.toFixed 2
                      storyPoints: us.total_points
                      status: us.status_extra_info.name
                      height: '1.4em'
                      sortable: false
                      classes: 'gantt-row-data'
                      color: ''
                      tasks: [
                        {
                          title: ''
                          color: '#992afe'
                          from: spr.estimated_start
                          to: if us.due_date then us.due_date else spr.estimated_finish
                          data: ''
                        }
                      ]
                      data: ''
                    }
        )

        toggleGantGraph = ->
            if $scope.isGanttGraphCollapsed
                hide(firstLoad)
            else
                show(firstLoad)

            firstLoad = false

        $scope.$watch "showGanttGraphPlaceholder", () ->
            if $scope.showGanttGraphPlaceholder?
                $scope.isGanttGraphCollapsed = $scope.isGanttGraphCollapsed || $scope.showGanttGraphPlaceholder
                toggleGantGraph()

        $el.on "click", ".gantt-button", ->
            $scope.isGanttGraphCollapsed = !$scope.isGanttGraphCollapsed
            $storage.set(hash, $scope.isGanttGraphCollapsed)
            toggleGantGraph()

        $scope.$on "$destroy", ->
            $el.off()


    return {
        link: link
    }

angular.module("taigaProjects").directive("tgToggleGanttVisibility", ["$tgStorage","$rootScope", "$timeout", ToggleGanttVisibility ])