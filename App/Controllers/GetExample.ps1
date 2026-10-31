[Route('GET', '/get-example')]
class GetExample {

    [Response] Response([string] $HttpMethod, [hashtable] $GET, [hashtable] $POST) {

        $html = "<!DOCTYPE html><html><body>"

        $html += "<h1>GET Example</h1>"

        $html += "<a>Data from hello: $($GET.hello)</a><br>"

        $html += "</body></html>"

        return [Response]::new(200, $html);
    }
}
