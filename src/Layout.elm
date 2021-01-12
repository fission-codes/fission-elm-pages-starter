module Layout exposing (view)

import Annotation exposing (Annotation)
import DocumentSvg
import Element exposing (Element)
import Element.Background
import Element.Border
import Element.Font as Font
import Element.Input
import Element.Region
import Html exposing (Html)
import Metadata exposing (Metadata)
import Pages
import Pages.Directory as Directory exposing (Directory)
import Pages.ImagePath as ImagePath
import Pages.PagePath as PagePath exposing (PagePath)
import Palette


view :
    { title : String, body : List (Element msg) }
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    ->
        { loginMsg : msg
        , username : Maybe String
        }
    ->
        { annotation : Annotation
        , onLoadAnnotation : String -> msg
        , onUpdateAnnotation : Annotation -> msg
        , onSaveAnnotation : Annotation -> msg
        , onCancelAnnotation : msg
        }
    -> { title : String, body : Html msg }
view document page fissionAuth annotationOptions =
    { title = document.title
    , body =
        Element.column
            [ Element.width Element.fill
            , Element.height Element.fill
            , Element.inFront <|
                case fissionAuth.username of
                    Just username ->
                        case page.frontmatter of
                            Metadata.Article metadata ->
                                Annotation.view
                                    { annotation = annotationOptions.annotation
                                    , title = metadata.title
                                    , onLoadAnnotation = annotationOptions.onLoadAnnotation
                                    , onUpdateAnnotation = annotationOptions.onUpdateAnnotation
                                    , onSaveAnnotation = annotationOptions.onSaveAnnotation
                                    , onCancelAnnotation = annotationOptions.onCancelAnnotation
                                    }

                            _ ->
                                Element.none

                    Nothing ->
                        Element.none
            ]
            [ header page.path fissionAuth
            , Element.column
                [ Element.padding 30
                , Element.spacing 40
                , Element.Region.mainContent
                , Element.width (Element.fill |> Element.maximum 800)
                , Element.centerX
                ]
                document.body
            ]
            |> Element.layout
                [ Element.width Element.fill
                , Font.size 20
                , Font.family [ Font.typeface "Roboto" ]
                , Font.color (Element.rgba255 0 0 0 0.8)
                ]
    }


header : PagePath Pages.PathKey -> { loginMsg : msg, username : Maybe String } -> Element msg
header currentPath fissionAuth =
    Element.column [ Element.width Element.fill ]
        [ Element.el
            [ Element.height (Element.px 4)
            , Element.width Element.fill
            , Element.Background.gradient
                { angle = 0.2
                , steps =
                    [ Element.rgb255 0 242 96
                    , Element.rgb255 5 117 230
                    ]
                }
            ]
            Element.none
        , Element.row
            [ Element.paddingXY 25 4
            , Element.spaceEvenly
            , Element.width Element.fill
            , Element.Region.navigation
            , Element.Border.widthEach { bottom = 1, left = 0, right = 0, top = 0 }
            , Element.Border.color (Element.rgba255 40 80 40 0.4)
            ]
            [ Element.link []
                { url = "/"
                , label =
                    Element.row [ Font.size 30, Element.spacing 16 ]
                        [ DocumentSvg.view
                        , Element.text "elm-pages-starter"
                        ]
                }
            , Element.row [ Element.spacing 15 ]
                [ fissionAuthButton fissionAuth
                , elmDocsLink
                , githubRepoLink
                , highlightableLink currentPath Pages.pages.blog.directory "Blog"
                ]
            ]
        ]


highlightableLink :
    PagePath Pages.PathKey
    -> Directory Pages.PathKey Directory.WithIndex
    -> String
    -> Element msg
highlightableLink currentPath linkDirectory displayName =
    let
        isHighlighted =
            currentPath |> Directory.includes linkDirectory
    in
    Element.link
        (if isHighlighted then
            [ Font.underline
            , Font.color Palette.color.primary
            ]

         else
            []
        )
        { url = linkDirectory |> Directory.indexPath |> PagePath.toString
        , label = Element.text displayName
        }


githubRepoLink : Element msg
githubRepoLink =
    Element.newTabLink []
        { url = "https://github.com/dillonkearns/elm-pages"
        , label =
            Element.image
                [ Element.width (Element.px 22)
                , Font.color Palette.color.primary
                ]
                { src = ImagePath.toString Pages.images.github, description = "Github repo" }
        }


elmDocsLink : Element msg
elmDocsLink =
    Element.newTabLink []
        { url = "https://package.elm-lang.org/packages/dillonkearns/elm-pages/latest/"
        , label =
            Element.image
                [ Element.width (Element.px 22)
                , Font.color Palette.color.primary
                ]
                { src = ImagePath.toString Pages.images.elmLogo, description = "Elm Package Docs" }
        }


fissionAuthButton : { loginMsg : msg, username : Maybe String } -> Element msg
fissionAuthButton fissionAuth =
    Element.Input.button
        []
        { onPress = Just fissionAuth.loginMsg
        , label =
            Element.row
                [ Element.spacing 2
                , Font.size 18
                ]
                [ Element.image
                    [ Element.width (Element.px 26)
                    ]
                    { src = ImagePath.toString Pages.images.fission
                    , description = "Login with Fission"
                    }
                , case fissionAuth.username of
                    Just username ->
                        Element.text username

                    Nothing ->
                        Element.none
                ]
        }
