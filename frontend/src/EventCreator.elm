module EventCreator exposing (Msg(..), DraftEvent, view, emptyDraft, textInputId)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onCheck, onSubmit, onClick)

type Msg
  = CreateEvent DraftEvent
  | UpdateDraft DraftEvent
  | Expand
  | Hide

type alias DraftEvent =
  { name: String
  , isBlocked: Bool
  }

textInputId : String
textInputId = "event-creator-input"

emptyDraft : DraftEvent
emptyDraft =
  { name = ""
  , isBlocked = False
  }

view : Bool -> DraftEvent -> Html Msg
view expanded draft =
  if expanded then
    div [] [
      Html.form [ onSubmit (CreateEvent draft) ] [
        input [ placeholder "Event name"
              , value draft.name
              , id textInputId
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
        , button [ onClick Hide ] [ text "Hide" ]
    ]
  else
    button [ onClick Expand ] [ text "+" ]
