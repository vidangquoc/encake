app.config ['flashProvider', (flashProvider)->

  flashProvider.errorClassnames.push("alert-danger")
  flashProvider.warnClassnames.push("alert-warning")
  flashProvider.infoClassnames.push("alert-info")
  flashProvider.successClassnames.push("alert-success")
  
]