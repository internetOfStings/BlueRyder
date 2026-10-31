using module ..\Attributes\Route.psm1
using module .\Response.psm1
using module .\Request.psm1

class Dispatcher {

    [hashtable] $getRoutes
    [hashtable] $postRoutes
    
    Dispatcher() {
        $this.getRoutes = @{}
        $this.postRoutes = @{}

        $controllers = Get-ChildItem -Path ((Split-Path -Parent $PSCommandPath) + '..\..\..\App\Controllers\') | Select-Object Name,FullName

        foreach ($controller in $controllers) {

            # Autoload controller
            . $controller.FullName

            # Get class name from the file name
            $classFromFileName = $controller.Name.Replace('.ps1', '') -as [type]
            $attr = $classFromFileName.GetCustomAttributes([Route], $false)

            # we could have multiple accepted route attributes (and do sometimes)
            foreach ($a in $attr) {
                # Adds routes to hash table so we can search for them when a request comes in
                if ($a.HttpMethod -eq 'GET') {
                    $this.getRoutes.Add($a.Route, $classFromFileName)
                } 

                if ($a.HttpMethod -eq 'POST') {
                    $this.postRoutes.Add($a.Route, $classFromFileName)
                } 
            }
        }
    }

    [Response] Dispatch([Request] $request) {

        if ($request.HttpMethod -eq 'GET' -and $this.getRoutes.ContainsKey($request.Route)) {

            $r = $this.getRoutes[$request.Route]
            $s = $r::new()
            return $s.Response($request.HttpMethod, $request.queryString, $request.Post)

        } elseif ($request.HttpMethod -eq 'POST') {

            $r = $this.postRoutes[$request.Route]
            $s = $r::new()
            return $s.Response($request.HttpMethod, $request.queryString, $request.Post)

        } else {

            return [Response]::new(404, '')

        }


    }
}
