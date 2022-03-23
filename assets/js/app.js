// Configure module entry points in "webpack.config.js".
// Import deps with the dep name or local files with a relative path, for example:
//     import socket from "./socket"
import Alpine from "alpinejs";
import "phoenix_html";
import { Socket } from "phoenix";
import topbar from "topbar";
import { LiveSocket } from "phoenix_live_view";
// import Hooks from "./_hooks";
import ApexCharts from "apexcharts";

let Hooks = {};

Hooks.Charts = {
  mounted() {
    initCharts(this);
  },
  updated() {
    renderCharts(this);
  },
};

function initCharts(hook) {
  var chartDiv = document.getElementById("chart");
  hook.chart = new ApexCharts(chartDiv, chartOptions);
  var overviewChartDiv = document.getElementById("overviewChart");
  hook.overviewChart = new ApexCharts(overviewChartDiv, overviewChartOptions);
  renderCharts(hook);

  hook.handleEvent("comparatorSeries", ({ data }) => {
    comparatorSeries = data;
    hook.chart.updateSeries([userSeries, comparatorSeries]);
    hook.overviewChart.updateSeries([userSeries, comparatorSeries]);
  });

  hook.handleEvent("userSeries", ({ data }) => {
    userSeries = data;
    hook.chart.updateSeries([userSeries, comparatorSeries]);
    hook.overviewChart.updateSeries([userSeries, comparatorSeries]);
  });
}

function renderCharts(hook) {
  hook.chart.render();
  hook.overviewChart.render();
}

window.Alpine = Alpine;
Alpine.start();

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    },
  },
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
// Show progress bar on live navigation and form submits
topbar.config({
  barColors: { 0: "#ffce54" },
  shadowColor: "rgba(0, 0, 0, .3)",
});
let topBarScheduled = undefined;

window.addEventListener("phx:page-loading-start", () => {
  if (!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 400);
  }
});

window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
window.ApexCharts = ApexCharts;
