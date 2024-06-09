from python import Python

fn main() raises:
    var streamlit = Python.import_module("streamlit")
    streamlit.title("GPT-3 Chat")