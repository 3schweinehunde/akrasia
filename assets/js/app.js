// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import deps with the dep name or local files with a relative path, for example:
//
//     import {Socket} from "phoenix"
//     import socket from "./socket"
//
import "alpinejs"
import "phoenix_html"
import {Socket} from "phoenix"
import NProgress from "nprogress"
import {LiveSocket} from "phoenix_live_view"
import ApexCharts from 'apexcharts'

let Hooks = {}

Hooks.Charts = {
  mounted() {
    initCharts(this)
  },
  updated() {
    renderCharts(this)
  }
}

function initCharts(hook) {
  var chartDiv = document.getElementById("chart")
  hook.chart = new ApexCharts(chartDiv, chartOptions)
  var overviewChartDiv = document.getElementById("overviewChart")
  hook.overviewChart = new ApexCharts(overviewChartDiv, overviewChartOptions)
  renderCharts(hook)

  hook.handleEvent("comparatorSeries", ({data}) => {
    comparatorSeries = data
    hook.chart.updateSeries([userSeries, comparatorSeries])
    hook.overviewChart.updateSeries([userSeries, comparatorSeries])
  })

  hook.handleEvent("userSeries", ({data}) => {
    userSeries = data
    hook.chart.updateSeries([userSeries, comparatorSeries])
    hook.overviewChart.updateSeries([userSeries, comparatorSeries])
  })
}

function renderCharts(hook) {
  hook.chart.render()
  hook.overviewChart.render()
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  dom: {
    onBeforeElUpdated(from, to){
      if(from.__x){ window.Alpine.clone(from.__x, to) }
    }
  },
  params: {_csrf_token: csrfToken},
  hooks: Hooks
})

// Show progress bar on live navigation and form submits
window.addEventListener("phx:page-loading-start", info => NProgress.start())
window.addEventListener("phx:page-loading-stop", info => NProgress.done())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
window.ApexCharts = ApexCharts
