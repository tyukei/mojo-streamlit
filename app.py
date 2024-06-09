import streamlit as st
import subprocess

img_path = 'img/mojoman.png'
if "chat_log" not in st.session_state:
    st.session_state.chat_log = []


def get_response_from_mojo(user_message, api_key):
    try:
        result = subprocess.run(
            ['mojo', 'mojo_backend.mojo', user_message, api_key],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return f"Error: {e.stderr}"

def main():
    st.title("Talke with 🔥-man")
    api_key = ""
    with st.sidebar:
        model = st.selectbox("Select model", ["gpt-2", "gpt-3.5"])
        if model == "gpt-3.5":
            st.link_button("Get API Key","https://platform.openai.com/api-keys")
            api_key = st.text_input("Enter openai api key", type="password", placeholder="Must enter")
        is_clear_chat = st.button("Clear chat")
        if is_clear_chat:
            st.session_state.chat_log = []
    if prompt := st.chat_input("ask me questions!"):
        for chat in st.session_state.chat_log:
            if chat["name"] == "User":
                with st.chat_message('User', avatar="👤"):
                    st.write(chat["msg"])
            else:
                with st.chat_message('Mojoman', avatar=img_path):
                    st.write(chat["msg"])

        with st.chat_message('User', avatar="👤"):
            st.write(prompt)
        with st.chat_message('Mojoman', avatar=img_path):
            with st.status("Calling 🔥...",expanded=True): 
                response = get_response_from_mojo(prompt, api_key)
                st.session_state.chat_log.append({"name": "User", "msg": prompt})
                st.session_state.chat_log.append({"name": "Mojoman", "msg": response})
                st.write(response)
if __name__ == "__main__":
    main()
