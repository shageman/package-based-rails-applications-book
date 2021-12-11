import consumer from "./consumer"

consumer.subscriptions.create("PredictionChannel", {
  received(data) {
    this.appendLine(data)
  },

  appendLine(data) {
    const html = this.createLine(data)
    const element = document.querySelector("#predictions")
    element.insertAdjacentHTML("beforeend", html)
  },

  createLine(data) {
    return `
      <article>
        <span>
          We predict that in <strong>${data.team_1_name}</strong> vs <strong>${data.team_2_name}</strong>. 
          The winner will be <strong>${data.winning_team_name}</strong>!
        </span>
      </article>
    `
  }
})

