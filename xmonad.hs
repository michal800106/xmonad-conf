--
-- xmonad example config file.
--
-- A template showing all available configuration hooks,
-- and how to override the defaults in your own xmonad.hs conf file.
--
-- Normally, you'd only override those defaults you care about.
--

{-# LANGUAGE FlexibleContexts #-}

import Control.Applicative ((<$>))
import System.IO ( stderr, hPutStrLn )
import System.Info ( os )

import XMonad
import XMonad.Hooks.UrgencyHook
        ( withUrgencyHook
        , NoUrgencyHook(NoUrgencyHook)
        )
import XMonad.Util.Run ( spawnPipe )

import qualified Events as EV ( myEventHook )
import qualified HostConfiguration as HC
import qualified Layout as LA ( myLayout )
import qualified Mappings as M ( myKeys, myMouseBindings )
import qualified ManageHook as MH ( myManageHook )
import qualified Settings as S
        ( myFocusFollowsMouse
        , myClickJustFocuses
        , myBorderWidth
        , myModMask
        , myInactiveColor
        , myFocusedBorderColor
        )
import qualified Workspaces as WS
        ( numberedWorkspaces
        , myXmonadBar
        , myLogHook
        )

xconfig conf xmobar = withUrgencyHook NoUrgencyHook $ defaultConfig
        {
                terminal           = HC.terminal conf,
                focusFollowsMouse  = S.myFocusFollowsMouse,
                clickJustFocuses   = S.myClickJustFocuses,
                borderWidth        = S.myBorderWidth,
                modMask            = S.myModMask,
                workspaces         = WS.numberedWorkspaces (HC.barMode conf) wsnames,
                normalBorderColor  = S.myInactiveColor,
                focusedBorderColor = S.myFocusedBorderColor,

                keys               = M.myKeys conf,
                mouseBindings      = M.myMouseBindings,

                layoutHook         = LA.myLayout (HC.barMode conf) wsnames,
                manageHook         = MH.myManageHook (HC.barMode conf) wsnames,
                handleEventHook    = EV.myEventHook,
                logHook            = WS.myLogHook xmobar conf,
                startupHook        = autostartAllPrograms conf
        }
        where wsnames = HC.workspaceNames conf

autostartAllPrograms :: HC.HostConfiguration -> X ()
autostartAllPrograms conf = do
        case os of
                "freebsd" -> spawn "~/.xmonad/lib/SysInfoBar"
                "openbsd" -> spawn $ "sysinfobar | " ++ (HC.mySysInfoBar $ HC.barMode conf)
                _         -> return ()
        mapM_ execprog $ HC.autostartPrograms conf
        where execprog prog = spawn $ (fst prog) ++ " " ++ (unwords $ snd prog)

main = do
        conf <- HC.readHostConfiguration
        hPutStrLn stderr $ show conf
        xmobar <- spawnPipe (WS.myXmonadBar $ HC.barMode conf)
        xmonad $ xconfig conf xmobar
