#[cfg(not(feature = "dylib"))]
pub use i3m_impl::*;

#[cfg(feature = "dylib")]
pub use i3m_dylib::*;
