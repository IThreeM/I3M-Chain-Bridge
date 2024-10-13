//! A crate that allows using IThreeM as a dynamically linked library. It could be useful for fast
//! prototyping, that can save some time on avoiding potentially time-consuming static linking
//! stage.
//!
//! The crate just re-exports everything from the engine, and you can use it as IThreeM. To use the
//! crate all you need to do is re-define `i3m` dependency in your project like so:
//!
//! ```toml
//! [dependencies.i3m]
//! version = "0.1.0"
//! registry = "i3m-dylib"
//! package = "i3m-dylib"
//! ```
//!
//! You can also use the latest version from git:
//!
//! ```toml
//! [dependencies.i3m]
//! git = "https://github.com/IThreeM/I3M-Engine-Core"
//! package = "i3m-dylib"
//! ```

// Just re-export everything.
pub use i3m_impl::*;
