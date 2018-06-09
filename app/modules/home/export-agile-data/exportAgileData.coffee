ExportAgileDataDirective = (http) ->
  link = (scope, el, attrs, ctrl) ->
    el.bind 'click', (e) ->
      config = { responseType: 'blob'}
      data = { project_id : $(el).attr("data-project-id") }
      promise = http.http.post('http://localhost:8000/api/v1/stats/agile_stats_export/', data, config)
      promise.success (data, status) ->
        projectName = ''
        $(el).parent().siblings().each (index) ->
          if $(this).attr("data-title") == 'projectName'
            projectName = $(this).text()

        a = document.createElement("a");
        document.body.appendChild(a);
        a.style = "display: none";
        url = window.URL.createObjectURL(data);
        a.href = url;
        currentDate = new Date().toJSON().slice(0,10)
        a.download = projectName + '_agileStats_' + currentDate + '.xls';
        a.click();
        window.URL.revokeObjectURL(url);
#    scope.vm = {}
  directive = {
    scope: {}
    link: link
  }

  return directive

ExportAgileDataDirective.$inject = [
  "$tgHttp"
]

angular.module("taigaHome").directive("tgExportAgileData", ExportAgileDataDirective)