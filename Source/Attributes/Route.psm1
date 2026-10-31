
class Route : System.Attribute {

    [string]$HttpMethod
    [string]$Route

    Route([string]$httpMethod, [string]$route) {
        $this.HttpMethod = $httpMethod
        $this.Route = $route
    }
}
