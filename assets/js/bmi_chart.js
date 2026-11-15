// BMI diagram (AkrasiaWeb.WeighingDiagramLive), drawn with ECharts (Apache 2.0;
// ApexCharts left MIT after 4.7, see backlog #51). Only the modules we use are
// bundled.
//
// Initial data comes from data attributes on the hook element, updates from
// push_event: "user-series" after a new weighing, "comparator-series" when a
// comparator is chosen. Colors follow the DaisyUI theme (Latte / Mocha) and
// are re-read when the theme changes.
import * as echarts from "echarts/core"
import {LineChart} from "echarts/charts"
import {
  DataZoomComponent,
  GridComponent,
  LegendComponent,
  MarkLineComponent,
  TooltipComponent,
} from "echarts/components"
import {CanvasRenderer} from "echarts/renderers"

echarts.use([
  LineChart,
  DataZoomComponent,
  GridComponent,
  LegendComponent,
  MarkLineComponent,
  TooltipComponent,
  CanvasRenderer,
])

function themeColor(name) {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim()
}

export const BmiChart = {
  mounted() {
    const {name, series, targetBmi, targetLabel} = this.el.dataset
    this.user = {name: name, data: JSON.parse(series)}
    this.comparator = {name: null, data: []}
    this.targetBmi = targetBmi ? parseFloat(targetBmi) : null
    this.targetLabel = targetLabel

    this.chart = echarts.init(this.el)
    this.render()

    this.handleEvent("user-series", ({name, data}) => {
      this.user = {name, data}
      this.render()
    })

    this.handleEvent("comparator-series", ({name, data}) => {
      this.comparator = {name, data}
      this.render()
    })

    this.onResize = () => this.chart.resize()
    this.onThemeChange = () => this.render()
    this.colorScheme = window.matchMedia("(prefers-color-scheme: dark)")
    window.addEventListener("resize", this.onResize)
    window.addEventListener("akrasia:theme-changed", this.onThemeChange)
    this.colorScheme.addEventListener("change", this.onThemeChange)
  },

  destroyed() {
    window.removeEventListener("resize", this.onResize)
    window.removeEventListener("akrasia:theme-changed", this.onThemeChange)
    this.colorScheme.removeEventListener("change", this.onThemeChange)
    this.chart.dispose()
  },

  // starts with the full history (user, 2026-11-15); a zoom the user sets
  // with the slider is kept on updates
  render() {
    const text = themeColor("--color-base-content")
    const grid = themeColor("--color-base-300")
    const userColor = themeColor("--color-primary")
    const comparatorColor = themeColor("--color-secondary")
    const targetColor = themeColor("--color-success")

    const series = [
      {
        name: this.user.name,
        type: "line",
        data: this.user.data,
        showSymbol: false,
        lineStyle: {width: 2},
        itemStyle: {color: userColor},
        markLine: this.targetBmi && {
          symbol: "none",
          silent: true,
          lineStyle: {type: "dashed", color: targetColor},
          label: {formatter: `${this.targetLabel} {c}`, color: text, position: "insideEndTop"},
          data: [{yAxis: this.targetBmi}],
        },
      },
    ]

    if (this.comparator.name) {
      series.push({
        name: this.comparator.name,
        type: "line",
        data: this.comparator.data,
        showSymbol: false,
        lineStyle: {width: 2},
        itemStyle: {color: comparatorColor},
      })
    }

    const dataZoom = [
      {type: "inside", filterMode: "none"},
      {
        type: "slider",
        filterMode: "none",
        bottom: 10,
        textStyle: {color: text},
        borderColor: grid,
      },
    ]

    this.chart.setOption(
      {
        textStyle: {color: text},
        tooltip: {trigger: "axis"},
        legend: {textStyle: {color: text}, top: 0},
        grid: {left: 50, right: 30, top: 40, bottom: 70},
        xAxis: {
          type: "time",
          axisLine: {lineStyle: {color: grid}},
          axisLabel: {color: text},
        },
        yAxis: {
          type: "value",
          name: "BMI",
          scale: true,
          nameTextStyle: {color: text},
          axisLabel: {color: text},
          splitLine: {lineStyle: {color: grid}},
        },
        dataZoom,
        series,
      },
      {replaceMerge: ["series"]},
    )
  },
}
