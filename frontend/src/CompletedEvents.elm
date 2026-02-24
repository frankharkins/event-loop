module CompletedEvents exposing (headerIconButton, modal, Msg(..))

import Html exposing (..)
import Html.Attributes exposing (..)

import Event exposing (Event)
import Carbon.Icons exposing (..)
import Utils.Modal as Modal
import Utils.HeaderIconButton

type Msg = Open | Close

headerIconButton : Html Msg
headerIconButton =
  Utils.HeaderIconButton.view "View completed" Open Carbon.Icons.taskComplete

type alias Model a =
  { a
  | completedModalOpen: Bool
  , completedEvents: List Event
  }

modal : Model a -> Html Msg
modal { completedModalOpen, completedEvents } =
  Modal.view completedModalOpen Close
    [ h2 [ class "font-bold text-title mb-4" ] [ text "Completed events" ]
    , ul []
      (List.map
        (\e -> li [ class "my-2" ] [ text e.name ])
        completedEvents
      )
    ]
