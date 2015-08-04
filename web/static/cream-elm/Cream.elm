module Cream where

import Char
import Html exposing (..)
import Html.Attributes as Attr exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json exposing ((:=))
import String
import Task exposing (..)


-- VIEW

view : String -> Result String (List String) -> Html
view string result =
  let field =
        input
          [ placeholder "Contact ID"
          , value string
          , on "input" targetValue (Signal.message query.address)
          , myStyle
          ]
          []

      messages =
        case result of
          Err msg ->
              [ div [ myStyle ] [ text msg ] ]

          Ok cities ->
              List.map (\city -> div [ myStyle ] [ text city ]) cities
  in
      div [] (field :: messages)


myStyle : Attribute
myStyle =
  style
    [ ("width", "100%")
    , ("height", "40px")
    , ("padding", "10px 0")
    , ("font-size", "2em")
    , ("text-align", "center")
    ]


-- WIRING

main =
  Signal.map2 view query.signal results.signal


query : Signal.Mailbox String
query =
  Signal.mailbox ""


results : Signal.Mailbox (Result String (List String))
results =
  Signal.mailbox (Err "A valid US zip code is 5 numbers.")


port requests : Signal (Task x ())
port requests =
  Signal.map lookupContact query.signal
    |> Signal.map (\task -> Task.toResult task `andThen` Signal.send results.address)


lookupZipCode : String -> Task String (List String)
lookupZipCode query =
  let toUrl =
        if String.length query == 5 && String.all Char.isDigit query
          then succeed ("http://api.zippopotam.us/us/" ++ query)
          else fail "Give me a valid US zip code!"
  in
      toUrl `andThen` (mapError (always "Not found :(") << Http.get places)


places : Json.Decoder (List String)
places =
  let place =
        Json.object2 (\city state -> city ++ ", " ++ state)
          ("place name" := Json.string)
          ("state" := Json.string)
  in
      "places" := Json.list place


lookupContact : String -> Task String (List String)
lookupContact query =
  let toUrl =
        if True
          then succeed ("http://localhost:4000/api/contacts")
          else fail "Give me a valid contact ID!"
  in
      toUrl `andThen` (mapError (always "Not found :(") << Http.get contacts)


contacts : Json.Decoder (List String)
contacts =
  let contact =
        Json.object3 (\first_name last_name email -> first_name ++ " " ++ last_name ++ " (" ++ email ++ ")")
          ("first_name" := Json.string)
          ("last_name" := Json.string)
          ("email" := Json.string)
  in
      "data" := Json.list contact
