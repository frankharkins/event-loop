module EventCreator exposing (Msg(..), DraftEvent, view, emptyDraft)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onCheck, onSubmit)

import Event exposing (Event)

type Msg
  = CreateEvent DraftEvent
  | UpdateDraft DraftEvent

type alias DraftEvent =
  { name: String
  , isBlocked: Bool
  }

emptyDraft : DraftEvent
emptyDraft =
  { name = ""
  , isBlocked = False
  }

view : DraftEvent -> Html Msg
view draft = Html.form [ onSubmit (CreateEvent draft) ] [
  input [ placeholder "Event name"
        , value draft.name
        , onInput (\s -> UpdateDraft { draft | name = s })
        ] []
  , div []
    [ input [ type_ "checkbox"
          , onCheck (\v -> UpdateDraft { draft | isBlocked = v })
          , checked draft.isBlocked
          ] []
    , text "blocked"
    ]
  , button [ type_ "submit" ] [ text "Add" ]
  ]
