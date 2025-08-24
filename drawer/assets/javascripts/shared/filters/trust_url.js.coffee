app.filter "trustUrl", ['$sce', ($sce) ->
  return (recordingUrl)-> $sce.trustAsResourceUrl(recordingUrl)
];