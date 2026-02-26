// S3-compatible uploader for direct browser-to-Tigris PUT uploads.
// Used by Phoenix LiveView's external upload mechanism via allow_upload/3.
let Uploaders = {}

Uploaders.S3 = function(entries, onViewError) {
  entries.forEach(entry => {
    let { url } = entry.meta
    let xhr = new XMLHttpRequest()

    onViewError(() => xhr.abort())

    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        entry.progress(100)
      } else {
        entry.error()
      }
    }

    xhr.onerror = () => entry.error()

    xhr.upload.addEventListener("progress", (event) => {
      if (event.lengthComputable) {
        let percent = Math.round((event.loaded / event.total) * 100)
        if (percent < 100) {
          entry.progress(percent)
        }
      }
    })

    xhr.open("PUT", url, true)
    xhr.setRequestHeader("Content-Type", entry.file.type)
    xhr.send(entry.file)
  })
}

export default Uploaders
