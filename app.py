import streamlit as st
import subprocess

def get_response_from_mojo(user_message):
    try:
        st.write("Sending message to Mojo...")
        result = subprocess.run(
            ['mojo', 'mojo_backend.mojo', user_message],
            capture_output=True,
            text=True,
            check=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return f"Error: {e.stderr}"

def main():
    st.title("Hello Mojo 🔥 with Streamlit")
    st.write("Welcome to Mojo with Streamlit")

    user_message = st.text_input("Enter your message:")
    if st.button("Send"):
        if user_message:
            response = get_response_from_mojo(user_message)
            st.write(f"Response: {response}")
        else:
            st.write("Please enter a message.")

if __name__ == "__main__":
    main()
