{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE InstanceSigs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE UndecidableInstances #-}

module EitherT
  ( EitherT (..),
    throwE,
  )
where

import Control.Monad (ap, liftM)
import Control.Monad.Cont (MonadTrans (..))
import Control.Monad.State (MonadState)
import Control.Monad.State.Class (MonadState (..))

newtype EitherT e m a = EitherT
  { runEitherT :: m (Either e a)
  }

instance (Monad m) => Functor (EitherT e m) where
  fmap :: (a -> b) -> EitherT e m a -> EitherT e m b
  fmap = liftM

instance (Monad m) => Applicative (EitherT e m) where
  pure :: a -> EitherT e m a
  pure = EitherT . return . Right
  (<*>) :: EitherT e m (a -> b) -> EitherT e m a -> EitherT e m b
  (<*>) = ap

instance (Monad m) => Monad (EitherT e m) where
  return :: a -> EitherT e m a
  return = pure
  (>>=) :: EitherT e m a -> (a -> EitherT e m b) -> EitherT e m b
  m >>= k =
    EitherT $
      runEitherT m >>= \case
        Left e -> return (Left e)
        Right x -> runEitherT (k x)

throwE :: (Monad m) => e -> EitherT e m a
throwE = EitherT . return . Left

instance MonadTrans (EitherT e) where
  lift :: (Monad m) => m a -> EitherT e m a
  lift m = EitherT (Right <$> m)

instance (MonadState s m) => MonadState s (EitherT e m) where
  get :: EitherT e m s
  get = lift get
  put :: s -> EitherT e m ()
  put k = lift (put k)