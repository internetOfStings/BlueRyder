class Request {

    # https://learn.microsoft.com/en-us/dotnet/api/system.net.httplistenerrequest?view=net-10.0

    [string]$RequestTraceIdentifier
    [string]$HttpMethod
    [boolean]$IsLocal
    [string]$RawUrl # Check MS docs, possible null value?, but i get error if I try to make this nullable.
    [string]$Route
    [uri]$Uri # keep as uri for now, lots of good methods, check here: https://learn.microsoft.com/en-us/dotnet/api/system.uri?view=net-10.0
    [hashtable]$Headers = @{}
    [hashtable]$queryString = @{}
    [string]$Body
    [string]$ContentType
    [hashtable]$Post = @{}



    Request (
        [object]$request # Only allow HTTPListernerRequest if you can. I cant figure it out right now.
    ) {
        $this.RequestTraceIdentifier = $request.RequestTraceIdentifier.ToString()
        $this.HttpMethod = $request.HttpMethod
        $this.IsLocal = $request.IsLocal
        $this.RawUrl = $request.RawUrl
        $this.Route = ($request.RawUrl.split('?'))[0]
        $this.uri = $request.Url
        $this.ContentType = $request.ContentType

        $reader = [System.IO.StreamReader]::new($request.InputStream, [System.Text.Encoding]::UTF8)
        $this.Body = $reader.ReadToEnd()

        # We have to parse all POST requests so we do that here.
        if ($this.ContentType -eq 'application/x-www-form-urlencoded' -and $this.HttpMethod -eq 'POST') {

            $temppost = [System.Web.HttpUtility]::ParseQueryString($this.Body)

            foreach ($key in $temppost) {
                $this.Post.Add($key, $temppost[$key])
            }

        } else {
            #not sure lol, do stuff here for other types such as json and whatnot
        }

        foreach ($key in $request.QueryString) {
            $this.queryString.Add($key, $request.QueryString[$key])
        }

        foreach ($key in $request.Headers) {
            $this.Headers.Add($key, $request.Headers[$key])
        }
    }

    [void]ScreenDump() {
        Write-Host $this.HttpMethod
        Write-Host $this.IsLocal
        Write-Host $this.RequestTraceIdentifier
        Write-Host $this.RawUrl
        Write-Host $this.Route
        Write-Host $this.Uri
        Write-Host $this.Headers.Connection
        Write-Host $this.Body
        Write-Host $this.ContentType
        $this.queryString.GetEnumerator() | ForEach-Object {
            Write-Host "Q-Key: $($_.Key), Q-Value: $($_.Value)"
        }
        $this.Post.GetEnumerator() | ForEach-Object {
            Write-Host "P-Key: $($_.Key), P-Value: $($_.Value)"
        }
    }
}