class Response {
    [int]$StatusCode
    [string]$Content

    Response (
        [int]$statusCode,
        [string]$content
    ) {
        $this.StatusCode = $statusCode
        $this.Content = $content
    }
}