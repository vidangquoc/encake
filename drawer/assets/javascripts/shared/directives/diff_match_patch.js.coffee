###
 angular-diff-match-patch
 http://amweiss.github.io/angular-diff-match-patch/
 @license: MIT
###

### global DIFF_INSERT, DIFF_DELETE, DIFF_EQUAL, diff_match_patch ###

#/ <reference path="typings/tsd.d.ts" />
angular.module('diff-match-patch', []).factory('dmp', ->
  displayType = 
    INSDEL: 0
    LINEDIFF: 1

  diffClass = (op) ->
    switch op
      when DIFF_INSERT
        return 'ins'
      when DIFF_DELETE
        return 'del'
      when DIFF_EQUAL
        return 'match'

  diffSymbol = (op) ->
    switch op
      when DIFF_EQUAL
        return ' '
      when DIFF_INSERT
        return '+'
      when DIFF_DELETE
        return '-'

  diffTag = (op) ->
    switch op
      when DIFF_EQUAL
        return 'span'
      when DIFF_INSERT
        return 'ins'
      when DIFF_DELETE
        return 'del'

  diffAttrName = (op) ->
    switch op
      when DIFF_EQUAL
        return 'equal'
      when DIFF_INSERT
        return 'insert'
      when DIFF_DELETE
        return 'delete'

  isEmptyObject = (o) ->
    Object.getOwnPropertyNames(o).length == 0

  getTagAttrs = (options, op, attrs) ->
    `var k`
    attrs = attrs or {}
    tagOptions = {}
    if angular.isDefined(options) and angular.isDefined(options.attrs)
      tagOptions = angular.copy(options.attrs[diffAttrName(op)] or {})
    if isEmptyObject(tagOptions) and isEmptyObject(attrs)
      return ''
    for k of attrs
      if angular.isDefined(tagOptions[k])
        # The attribute defined in attrs should be first
        tagOptions[k] = attrs[k] + ' ' + tagOptions[k]
      else
        tagOptions[k] = attrs[k]
    lis = []
    for k of tagOptions
      lis.push k + '="' + tagOptions[k] + '"'
    ' ' + lis.join(' ')

  getHtmlPrefix = (op, display, options) ->
    retVal = ''
    switch display
      when displayType.LINEDIFF
        retVal = '<div class="' + diffClass(op) + '"><span' + getTagAttrs(options, op, 'class': 'noselect') + '>' + diffSymbol(op) + '</span>'
      when displayType.INSDEL
        tag = diffTag(op)
        retVal = '<' + tag + getTagAttrs(options, op) + '>'
    retVal

  getHtmlSuffix = (op, display) ->
    retVal = ''
    switch display
      when displayType.LINEDIFF
        retVal = '</div>'
      when displayType.INSDEL
        retVal = '</' + diffTag(op) + '>'
    retVal
  
  ###*
  # Split two texts into an array of words.  Reduce the texts to a string of
  # hashes where each Unicode character represents one line.
  # @param {string} text1 First string.
  # @param {string} text2 Second string.
  # @return {{chars1: string, chars2: string, wordArray: !Array.<string>}}
  #     An object containing the encoded text1, the encoded text2 and
  #     the array of unique words.
  #     The zeroth element of the array of unique words is intentionally blank.
  # @private
  ###
  
  wordsToChars = (text1, text2) ->
    wordArray = [] # e.g. wordArray[4] == 'Hello\n'
    wordHash = {} # e.g. wordHash['Hello\n'] == 4
    # '\x00' is a valid character, but various debuggers don't like it.
    # So we'll insert a junk entry to avoid generating a null character.
    wordArray[0] = '\x00';
    
    ###*
    # Split a text into an array of words.  Reduce the texts to a string of
    # hashes where each Unicode character represents one word.
    # Modifies wordarray and wordhash through being a closure.
    # @param {string} text String to encode.
    # @return {string} Encoded string.
    # @private
    ###
  
    wordsToCharsMunge = (text) ->
      text = text.replace(/\s/, ' ')
      chars = ''
      
      wordArrayLength = wordArray.length
      #while wordEnd < text.length - 1
      #  wordEnd = text.indexOf(' ', wordStart)
      #  if wordEnd == -1
      #    wordEnd = text.length - 1
      #  word = text.substring(wordStart, wordEnd + 1)
      #  wordStart = wordEnd + 1
      #  if (if wordHash.hasOwnProperty then wordHash.hasOwnProperty(word) else wordHash[word] != undefined)
      #    chars += String.fromCharCode(wordHash[word])
      #  else
      #    chars += String.fromCharCode(wordArrayLength)
      #    wordHash[word] = wordArrayLength
      #    wordArray[wordArrayLength++] = word
      
      #while wordEnd < text.length - 1
        #wordEnd = text.indexOf(' ', wordStart)
        #if wordEnd == -1
        #  wordEnd = text.length - 1
        #word = text.substring(wordStart, wordEnd + 1)
        #wordStart = wordEnd + 1
      
      words = text.split(/([\s|\.\?\,\!\:\"\'])/)
      
      for word in words when word != ""
        
        if (if wordHash.hasOwnProperty then wordHash.hasOwnProperty(word) else wordHash[word] != undefined)
          chars += String.fromCharCode(wordHash[word])
        else
          chars += String.fromCharCode(wordArrayLength)
          wordHash[word] = wordArrayLength
          wordArray[wordArrayLength++] = word
      
      chars
                  
    chars1 = wordsToCharsMunge(text1)
    chars2 = wordsToCharsMunge(text2)
    {
      chars1: chars1
      chars2: chars2
      wordArray: wordArray
    }
    
  diffWords = (left, right) ->
    
    dmp = new diff_match_patch
    a = wordsToChars(left, right)
    text1 = a.chars1
    text2 = a.chars2
    return {diffs: dmp.diff_main(text1, text2), wordArray: a.wordArray}

  ###*
  # Rehydrate the text in a diff from a string of word hashes to real text.
  # 
  # @param {!Array.<!diff_match_patch.Diff>} diffs Array of diff tuples.
  # @param {!Array.<string>} wordArray Array of unique words.
  # @private
  ###
  
  charsToWords = (diffs, wordArray) ->
    x = 0
    while x < diffs.length
      chars = diffs[x][1]
      text = []
      y = 0
      while y < chars.length
        text[y] = wordArray[chars.charCodeAt(y)]
        y++
      diffs[x][1] = text.join('')
      x++


  createHtmlLines = (text, op, options) ->
    lines = text.split('\n')
    y = 0
    while y < lines.length
      if lines[y].length == 0
        y++
        continue
      lines[y] = getHtmlPrefix(op, displayType.LINEDIFF, options) + lines[y] + getHtmlSuffix(op, displayType.LINEDIFF)
      y++
    lines.join ''

  createHtmlFromDiffs = (diffs, display, options) ->
    pattern_amp = /&/g
    pattern_lt = /</g
    pattern_gt = />/g
    text = ''
    x = 0
    while x < diffs.length
      data = diffs[x][1]
      text = data.replace(pattern_amp, '&amp;').replace(pattern_lt, '&lt;').replace(pattern_gt, '&gt;')
      diffs[x][1] = text
      x++
    html = []
    x = 0
    while x < diffs.length
      op = diffs[x][0]
      text = diffs[x][1]
      if display == displayType.LINEDIFF
        html[x] = createHtmlLines(text, op, options)
      else
        html[x] = getHtmlPrefix(op, display, options) + text + getHtmlSuffix(op, display)
      x++
    html.join ''

  assertArgumentsIsStrings = (left, right) ->
    angular.isString(left) and angular.isString(right)

  {
    createDiffHtml: (left, right, options) ->
      if assertArgumentsIsStrings(left, right)
        dmp = new diff_match_patch
        diffs = dmp.diff_main(left, right)
        createHtmlFromDiffs diffs, displayType.INSDEL, options
      else
        ''
    createProcessingDiffHtml: (left, right, options) ->
      if assertArgumentsIsStrings(left, right)
        dmp = new diff_match_patch
        diffs = dmp.diff_main(left, right)
        #dmp.Diff_EditCost = 4;
        dmp.diff_cleanupEfficiency diffs
        createHtmlFromDiffs diffs, displayType.INSDEL, options
      else
        ''
    createSemanticDiffHtml: (left, right, options) ->
      if assertArgumentsIsStrings(left, right)
        dmp = new diff_match_patch
        diffs = dmp.diff_main(left, right)
        dmp.diff_cleanupSemantic diffs
        createHtmlFromDiffs diffs, displayType.INSDEL, options
      else
        ''
    createWordDiffHtml: (left, right, options) ->
      
      wordsMatch = (word1, word2)->
        
        wordsAreNumbersAndMatch(word1, word2) ||
        
        wordsCaseInsensitiveMatch(word1, word2)
      
      wordsAreNumbersAndMatch = (word1, word2) ->
        
        word1 == word2 #temporary
      
      wordsCaseInsensitiveMatch = (word1, word2)->
        
        word1.toLowerCase() == word2.toLowerCase()
        
      wordContainsOnlyPeriods = (word) ->
        
        word.replace(/[.,?!:;'"]+/g, '') == ''
      
      if assertArgumentsIsStrings(left, right)
        
        diffs = diffWords(left, right)
        charsToWords diffs.diffs, diffs.wordArray
        
        case_insensitive_diffs = []
        for operation, index in diffs.diffs
          previous_operation = diffs.diffs[index - 1]
          next_operation = diffs.diffs[index + 1]
          if operation[0] == -1 && next_operation? && ( wordsMatch(operation[1], next_operation[1]) || wordContainsOnlyPeriods(operation[1]) )
            operation[0] = 0
          if operation[0] == +1 && previous_operation? && ( wordsMatch(operation[1], previous_operation[1]) || wordContainsOnlyPeriods(operation[1]) )
            continue
          case_insensitive_diffs.push(operation)
          
        #new diff_match_patch().diff_cleanupSemantic(case_insensitive_diffs)
        # Eliminate freak matches (e.g. blank lines)
        createHtmlFromDiffs case_insensitive_diffs, displayType.INSDEL, options
      else
        ''
    findNearestDiff: (source, dests, prioritizedDest) ->
      
      diffLengths = (@_diffLength(source, dest) for dest in dests)
        
      minLength = Math.min.apply @, diffLengths
      
      if prioritizedDest? && @_diffLength(source, prioritizedDest) == minLength
        
        return prioritizedDest 
      
      for dest in dests
        
        if @_diffLength(source, dest) == minLength
          
          return dest
    
    #findNearestDiffByWords: (source, dests, prioritizedDest) ->
    #  
    #  diffLengths = (@_diffLengthByWords(source, dest) for dest in dests)
    #    
    #  console.log diffLengths
    #    
    #  minLength = Math.min.apply @, diffLengths
    #  
    #  if prioritizedDest? && @_diffLengthByWords(source, prioritizedDest) == minLength
    #    
    #    return prioritizedDest 
    #  
    #  for dest in dests
    #    
    #    if @_diffLengthByWords(source, dest) == minLength
    #      
    #      return dest
    #    
    _diffLength: (source, dest) -> new diff_match_patch().diff_main(source, dest).length
      
    #_diffLengthByWords: (source, dest) ->
    #  diffs = diffWords(source, dest)
    #  diffs.diffs.length  
  }
).directive('diff', ['$compile', 'dmp', ($compile, dmp) ->
    ddo = 
      scope:
        left: '=leftObj'
        right: '=rightObj'
        options: '=options'
      link: (scope, iElement) ->

        listener = ->
          iElement.html dmp.createDiffHtml(scope.left, scope.right, scope.options)
          $compile(iElement.contents()) scope

        scope.$watch 'left', listener
        scope.$watch 'right', listener
        
    ddo
]).directive('processingDiff', ['$compile','dmp', ($compile, dmp) ->
    ddo = 
      scope:
        left: '=leftObj'
        right: '=rightObj'
        options: '=options'
      link: (scope, iElement) ->

        listener = ->
          iElement.html dmp.createProcessingDiffHtml(scope.left, scope.right, scope.options)
          $compile(iElement.contents()) scope

        scope.$watch 'left', listener
        scope.$watch 'right', listener
        
    ddo
    
]).directive('semanticDiff', ['$compile','dmp',($compile, dmp) ->
    ddo = 
      scope:
        left: '=leftObj'
        right: '=rightObj'
        options: '=options'
      link: (scope, iElement) ->

        listener = ->
          iElement.html dmp.createSemanticDiffHtml(scope.left, scope.right, scope.options)
          $compile(iElement.contents()) scope

        scope.$watch 'left', listener
        scope.$watch 'right', listener
    ddo    
]).directive('wordDiffMany', ['$compile','dmp',($compile, dmp) ->
  
    scope:
      left: '=leftObj'
      right: '=rightObjs'
      options: '=options'
      
    link: (scope, iElement) ->
      
      listener = ->
        left = scope.left || ''
        dests = scope.right || ['']
        dests = ( (if dest? then dest else '') for dest in dests)
        
        nearestDest = dmp.findNearestDiff(left, dests)
        iElement.html dmp.createWordDiffHtml(left + ' ', nearestDest + ' ', scope.options)
        $compile(iElement.contents()) scope

      scope.$watch 'left', listener
      scope.$watch 'right', listener
])
