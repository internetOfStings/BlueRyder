[Route('GET', '/post-example')]
[Route('POST', '/post-example')]
class PostExample {

    [Response] Response([string] $HttpMethod, [hashtable] $GET, [hashtable] $POST) {

        if ($HttpMethod -eq 'GET') {
            $html = '
            <!DOCTYPE html>
            <html>
            <body>

            <h2>POST Example</h2>
            <h3>Create File</h3>

            <form action="/post-example" method="POST">

                <label for="path">File Path:</label><br>
                <input style="width: 25rem;" type="text" id="path" name="path" value="C:\Users\Public\Documents"><br>

                <label for="name">File Name:</label><br>
                <input style="width: 25rem;" type="text" id="name" name="name" value="PostExample.txt"><br><br>

                <label for="content">File Content:</label><br>
                <input style="width: 25rem;" type="text" id="content" name="content" value="This is some text for the POST Example file."><br><br>

                <input type="submit" value="Submit">

            </form> 

            <p>Click Submit. Data will be posted to /post-example (this page) to be processed.</p>

            </body>
            </html>
            '

        } else {

            $html = 
            "
                <!DOCTYPE html><html><body>

                <h2>POST Example</h2>
                <h3>Create File?</h3>

                <p>NO, I didn't make that file... but here is the data you entered.</p>
                    <br>
                <p>$($POST.path)</p>
                    <br>
                <p>$($POST.name)</p>
                    <br>
                <p>$($POST.content)</p>

                </body></html>
            "
        }
        return [Response]::new(200, $html)
    }
}