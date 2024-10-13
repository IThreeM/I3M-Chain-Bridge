use std::env;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

fn main() {
    // Get the build information
    let rustc_version = env::var("RUSTC_VERSION").unwrap_or_else(|_| rustc_version().unwrap_or_else(|| "Unknown".to_string()));
    let profile = env::var("PROFILE").unwrap_or_else(|_| "Unknown".to_string());
    let target = env::var("TARGET").unwrap_or_else(|_| "Unknown".to_string());
    let debug = env::var("DEBUG").unwrap_or_else(|_| "Unknown".to_string());

    // Path to write the build information
    let out_dir = env::var("OUT_DIR").unwrap();
    let build_info_path = PathBuf::from(out_dir).join("build_info.txt");

    // Write build information to the file
    let mut file = File::create(&build_info_path).expect("Could not create file");
    writeln!(file, "Rustc Version: {}", rustc_version).expect("Could not write to file");
    writeln!(file, "Profile: {}", profile).expect("Could not write to file");
    writeln!(file, "Target: {}", target).expect("Could not write to file");
    writeln!(file, "Debug: {}", debug).expect("Could not write to file");

    println!("Build info written to {:?}", build_info_path);
}

fn rustc_version() -> Option<String> {
    use std::process::Command;

    let output = Command::new("rustc").arg("--version").output().ok()?;
    Some(String::from_utf8_lossy(&output.stdout).trim().to_string())
}
