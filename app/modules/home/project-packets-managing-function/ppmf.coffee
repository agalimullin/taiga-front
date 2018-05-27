ProjPacketsManagFuncDirective = (currentUserService) ->
  link = (scope, el, attrs, ctrl) ->
    scope.vm = {}
    taiga.defineImmutableProperty(scope.vm, "projects", () -> currentUserService.projects.get("all"))
  directive = {
    templateUrl: "home/project-packets-managing-function/ppmf.html"
    scope: {}
    link: link
  }

  return directive

ProjPacketsManagFuncDirective.$inject = [
  "tgCurrentUserService"
]

angular.module("taigaHome").directive("tgProjectPacketsList", ProjPacketsManagFuncDirective)