using module .\Response.psm1
using module .\Request.psm1
using module .\Dispatcher.psm1

$http = [System.Net.HttpListener]::new() 

# Hostname and port to listen on
$http.Prefixes.Add("http://localhost:8080/")

$http.Start()

while ($http.IsListening) {

    Write-Host "Server Listened"

    #NOTE: GetContext() is what waits for a http request (it hangs here).
    $context = $http.GetContext()

    #NOTE: becuase the GetContent() hangs the server until a request comes in, you currently cannot terminate the server until atleast 1 request comes in after the termination is requested
    if ($_br_.WebService.TerminateServer) {
        $http.Abort()
        $http.Close()
        Break;
    } else {

        $request = [Request]::new($context.Request)
        $disp = [Dispatcher]::new()
        $request.ScreenDump()
        $response = $disp.Dispatch($request)

        # Converts html to byte stream then sends it as a response.
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($response.Content)
        $context.Response.StatusCode = $response.StatusCode
        $context.Response.ContentLength64 = $buffer.Length
        $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
        $context.Response.OutputStream.Close() # close the response
    }
}

$http.Stop()