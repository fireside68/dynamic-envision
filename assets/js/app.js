// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")

let Hooks = {}

// Ken Burns slideshow hook
Hooks.KenBurns = {
  mounted() {
    this.currentIndex = 0
    this.images = JSON.parse(this.el.dataset.images || "[]")
    this.interval = 6000 // 6 seconds per image

    // Find the parent LiveComponent element
    this.component = this.el.closest('[data-phx-component]')

    if (this.images.length > 0) {
      this.startSlideshow()
    }
  },

  startSlideshow() {
    this.timer = setInterval(() => {
      this.currentIndex = (this.currentIndex + 1) % this.images.length
      // Push event to the LiveComponent, not the parent LiveView
      if (this.component) {
        this.pushEventTo(this.component, "update_hero_image", {index: this.currentIndex})
      }
    }, this.interval)
  },

  destroyed() {
    if (this.timer) {
      clearInterval(this.timer)
    }
  }
}

// Mobile menu toggle hook
Hooks.MobileMenu = {
  mounted() {
    // Find the parent LiveComponent element
    this.component = this.el.closest('[data-phx-component]')

    this.handleEscape = (e) => {
      if (e.key === "Escape" && this.component) {
        this.pushEventTo(this.component, "close_mobile_menu", {})
      }
    }

    window.addEventListener("keydown", this.handleEscape)
  },

  destroyed() {
    window.removeEventListener("keydown", this.handleEscape)
  }
}

// Smooth scroll hook
Hooks.SmoothScroll = {
  mounted() {
    this.el.addEventListener("click", (e) => {
      e.preventDefault()
      const targetId = this.el.getAttribute("href")
      const target = document.querySelector(targetId)

      if (target) {
        target.scrollIntoView({
          behavior: "smooth",
          block: "start"
        })

        // Close mobile menu if open - find the navigation component
        const navComponent = document.querySelector('[data-phx-component]')
        if (navComponent) {
          // The phx-click handler on the link will handle closing
          // We don't need to push the event here since phx-click already does it
        }
      }
    })
  }
}

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#b45309"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
