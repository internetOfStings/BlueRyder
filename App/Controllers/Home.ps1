[Route('GET', '/')]
[Route('GET', '/home')]
class Home {

    [Response] Response([string] $HttpMethod, [hashtable] $GET, [hashtable] $POST) {

        $html = "<!DOCTYPE html><html><body>"

        $html += "<h1>BlueRyder</h1>"

        $html += '<a href="/get-example?hello=world">GET Example</a><br>'
        $html += '<a href="/post-example">POST Example</a><br>'
        $html += '<a href="/aes-example">AES Example</a><br>'

        $html += "</body></html>"

        return [Response]::new(200, $html);
    }
}