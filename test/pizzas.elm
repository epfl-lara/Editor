edit  = listDict.get "edit" vars == Just "true"
admin = listDict.get "admin" vars == Just "true"
mbReplaceAdmin hint = if admin then Maybe.withDefaultReplace else Maybe.withDefaultReplace << (Update.lens { apply = identity, update = always <| Err """Cannot change the @hint without ?admin=true"""})
user  = listDict.get "user" vars |> mbReplaceAdmin "default name" "Anonymous"
hl    = listDict.get "hl" vars |> mbReplaceAdmin "default language" "en"

userdata = [
    ("Mikael", 2)
  , ("Ravi", 4)
  , ("Laurent", 2)
  ]
  
options = fs.read "data/pizzas.txt"
  |> Maybe.withDefaultReplace (freeze """[
    "$Margharita",
    "$Queen",
    "Montagnarde",
    "Barbecue"]""")
  |> evaluate

dictionnaire = [
  ("English", [ ("abbreviation", "en")
              , ("Salut", "Hey")
              , ("Tuveuxquellepizza", "Which pizza do you want")
              , ("achoisiunepizza", "wants a pizza")
              , ("Choisistapizza", "Choose your pizza")
              , ("Margharita", "Margharita")
              , ("Queen", "Queen")
              , ("Montagnarde", "Mountain")
              ]),
  ("Français", [ ("abbreviation", "fr")
               , ("Salut", "Salut")
               , ("Tuveuxquellepizza", "Tu voudrais quelle pizza")
               , ("achoisiunepizza", "a choisi une pizza")
               , ("Choisistapizza", "Choisis ta pizza")
               , ("Margharita", "Margherita")
               , ("Queen", "Reine")
               , ("Montagnarde", "Montagnarde")
               ])
]

abbreviations = dictionnaire |>
   List.map (\(name, trads) ->
     listDict.get "abbreviation" trads
     |> Maybe.withDefault name)

indexLangue = 
  List.findByAReturnB Tuple.second Tuple.first hl (List.zipWithIndex abbreviations)
  |> Maybe.withDefaultReplace (freeze 0)

main = Html.translate dictionnaire indexLangue <|
<html><head></head>
  <body>
  <span>$Salut @user! <br>
$Tuveuxquellepizza?
@Html.select[]("$Choisistapizza"::options)(
  listDict.get user userdata
  |> Maybe.orElseReplace (freeze (Just 0))
  |> Maybe.getUnless ((==) 0))
<br><br>
@(Html.select [] (List.map Tuple.first dictionnaire) indexLangue)<br><br>
 Final choices:<br>
@(List.map (\(name, id) ->
  <span>@name $achoisiunepizza @(List.findByAReturnB Tuple.first Tuple.second (id - 1) (List.zipWithIndex options) |> Maybe.withDefaultReplace (freeze "qui n'existe pas")).<br></span>
) userdata)
</span></body></html>