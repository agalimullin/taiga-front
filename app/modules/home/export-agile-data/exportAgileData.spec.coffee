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
# File: home-project-list-directive.spec.coffee
###

describe "exportAgileDataDirectiveDirective", () ->
    scope = compile = provide = null
    mocks = {}

    createDirective = () ->
        elm = compile(template)(scope)
        return elm

    _mockTgCurrentUserService = () ->
        mocks.http = {}

        provide.value "tgCurrentUserService", mocks.http

#    _mockTranslateFilter = () ->
#        mockTranslateFilter = (value) ->
#            return value
#        provide.value "translateFilter", mockTranslateFilter
#
#    _mocks = () ->
#        module ($provide) ->
#            provide = $provide
#            _mockTgCurrentUserService()
#            _mockTranslateFilter()
#            return null
#
#    beforeEach ->
#        module "templates"
#        module "taigaHome"
#
#        _mocks()
#
#        inject ($rootScope, $compile) ->
#            scope = $rootScope.$new()
#            compile = $compile
#
#        recents = Immutable.fromJS([
#            {
#                id:1
#            },
#            {
#                id: 2
#            }
#        ])
#
#    it "project packets  list directive scope content", () ->
#        elm = createDirective()
#        scope.$apply()
#        expect(elm.isolateScope().vm.projects.size).to.be.equal(3)
