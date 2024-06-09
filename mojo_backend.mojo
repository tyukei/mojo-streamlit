from python import Python
from sys import argv

fn generate_response(user_message: String) -> String:
    try:
        var openai = Python.import_module("openai")
        var os = Python.import_module("os")
        var dot_env = Python.import_module("dotenv")
        dot_env.load_dotenv()
        var api_key = os.getenv('OPENAI_KEY')
        var client = openai.OpenAI(api_key=api_key)
        
        var dictionary = Python.dict()
        dictionary["role"] = "user"
        dictionary["content"] = user_message
        
        var messages = Python.list()
        messages.append(dictionary)
        
        var completion = client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=messages
        )
        
        var response = completion.choices[0].message.content
        return response
    except e:
        return str(e)

fn main() raises:
    var message = argv()[1]
    var response = generate_response(message)
    print(response)
