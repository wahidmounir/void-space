{-# LANGUAGE OverloadedStrings #-}

module Display.Render where

import           Brick
import           Brick.Widgets.Center
import           Control.Arrow                            ( (&&&) )
import           Control.Lens
import           Control.Monad.State
import           Data.Art
import           Data.Enemies
import           Data.GameState
import           Data.List
import           Data.Maybe
import           Data.Words
import           Display.Attrs
import           Display.Dashboard
import           Display.Stars
import qualified Data.Map                      as M
import qualified Data.Text                     as T
import           Brick.Markup

drawWormhole :: GameState n -> Widget r
drawWormhole s = withAttr wormholeAttr $ txt (s ^. wormhole)

drawCorridor :: GameState n -> Widget String
drawCorridor s =
  drawShip s
    <+> hLimit 50 (padRight Max (drawEnemies s (evalState corridorSize s)))
    <+> drawWormhole s

drawShip :: GameState n -> Widget String
drawShip s = withAttr shipAttr $ txt (s ^. ship)

drawGame :: GameState n -> [Widget String]
drawGame s =
  [header, hCenterLayer . vCenterLayer $ drawCorridor s, stars <=> dashboard s]

drawEnemies :: GameState n -> Int -> Widget String
drawEnemies s sz = vBox $ foldMap (pure . widgetForRow) [0 .. sz]
 where
  widgetForRow :: Int -> Widget n
  widgetForRow i = fromMaybe (str . take 100 $ infiniteStarField i)
                             (sortedEnemies ^? ix i . to (toWidget i))
  toWidget i e =
    let widget = wordWidget (e ^. word) in addPadding i (e ^. distance) widget
  addPadding i amt w = txt (T.pack $ take amt (infiniteStarField i)) <+> w
  sortedEnemies = M.fromList $ (_row &&& id) <$> sortOn
    _distance
    (s ^.. enemies . traversed . _Just)

header :: Widget n
header = hCenterLayer $ markup ("VOID" @? redAttr <> "SPACE" @? cyanAttr)
