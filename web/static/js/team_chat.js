let TeamChat = {
  init(socket, element, teamId) {
    if (!element) {
      return
    }
  
    socket.onOpen( ev => console.log("OPEN", ev) )
    socket.onError( ev => console.log("ERROR", ev) )
    socket.onClose( e => console.log("CLOSE", e))

    let inputEl = $(element)

    socket.connect()
    let teamIdChannel = socket.channel("team-chats:" + teamId)
    teamIdChannel.onError(e => console.log("something went wrong", e))
    teamIdChannel.onClose(e => console.log("channel closed", e))

    teamIdChannel
      .on("message:add", (payload) => {
        console.log("message to add", payload)
      })
  }
}

export default TeamChat
