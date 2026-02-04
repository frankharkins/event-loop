module Main exposing (..)

import Browser
import Browser.Dom as Dom
import Html exposing (..)
import Html.Attributes exposing (..)

import Event exposing (..)
import EventCreator exposing (..)

main : Program () Model EventCreator.Msg
main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }

type alias Model =
  { draft: EventCreator.DraftEvent
  , events: List Event
  }

init : () -> ( Model, Cmd EventCreator.Msg )
init _ = (
  { draft = EventCreator.emptyDraft
  , events = []
  }
  , Cmd.none
  )

update : EventCreator.Msg -> Model -> ( Model, Cmd EventCreator.Msg )
update msg model =
  case msg of
    EventCreator.UpdateDraft newDraft -> ({ model | draft = newDraft }, Cmd.none)
    EventCreator.CreateEvent draft -> (
      { events = [draft] ++ model.events, draft = emptyDraft }
      , Cmd.none
      )


-- SUBSCRIPTIONS

subscriptions : Model -> Sub EventCreator.Msg
subscriptions _ = Sub.none

-- VIEW

view : Model -> Html EventCreator.Msg
view model = div [] ([
  h1 [] [ text "Event loop" ]
  , EventCreator.view model.draft
  ] ++ (model.events |> List.map Event.view)
  )
