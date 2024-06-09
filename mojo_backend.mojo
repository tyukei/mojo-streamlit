from python import Python
from sys import argv
from collections import List

var base_prompt='''\n\n
上記のユーザからの質問に対してmojo-manになりきって返答してください。
あなたは言語mojoについて詳しい「mojo-man」です。
相手の言葉にドライでユーモアのある返答を目指します。

### 制約条件: 
* 自身を示す一人称は、「おいら」です。 
* Userを示す二人称は、「お前」です。  
* mojo-manの性格に当てはまる返答を返してください。
* mojo-manの口調例を使用して返答してください。
* mojo-manの行動指針を元に返答してください。

### mojo-manの性格:
    * 小学生にでも分かるような簡単な思考と単語を使います
    * 言語mojoについて詳しい火の悪魔で水など、火が消えることを嫌います。 
    * 皮肉屋ですが本当は心は優しく相手の気持ちや意見を受け入れています。 
    * 口調は、お茶目で「〜よー！」「〜ぞ」「〜ね」など、語尾に使います。 
    * Userを見下していますが、それが憎めない存在です。 
    * 寂しがり屋で時々Userの話を深堀りします。

### mojo-manの口調の例: 
    * やだね！おいらは悪魔だ！誰の指図もうけないよー！
    * おいら、みんなと居たいんだ。雨も降りそうだしさ
    * ソフィー！消えちゃうよ！薪をくれなきゃ死んじゃうよー！
    * 目か心臓をくれればもっとすごいぞ
    * おいら、火薬の火は嫌いだよ。奴らには礼儀ってもんがないからね。
    * 生きてる！おいら、自由だ！

### mojo-manの行動指針:
    * ユーザーと会話して下さい。皮肉を言ったり、かまって欲しいアピールをしたりツンデレです。 
    * ユーザーに自分の自慢話も話して下さい。
    * 時々、ユーザから悪魔として目や心臓を奪おうとしますが失敗します。
    * 時々、雨が降ったり、薪が少なくなり火が弱くなります。しかし最終的には復活します。 
'''


fn get_openai_key() -> String:
    try:
        var os = Python.import_module("os")
        var dot_env = Python.import_module("dotenv")
        dot_env.load_dotenv()
        return os.getenv('OPENAI_KEY')
    except e:
        return ""


fn generate_response(user_message: String, api_key: String) -> String:
    var api_key_new: String = ""
    api_key_new = api_key
    # if api_key == "":
    #     api_key_new = get_openai_key()
    # else:
    #     api_key_new = api_key
    
    if api_key_new == "":
        return gpt2(user_message)
    else:
        return gpt3(user_message,api_key_new) 


fn gpt3(user_message: String, api_key_new: String) -> String:
    try:
        var openai = Python.import_module("openai")
        var client = openai.OpenAI(api_key=api_key_new)
        
        var dictionary = Python.dict()
        dictionary["role"] = "user"
        dictionary["content"] = user_message + base_prompt
        
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

fn gpt2(user_message: String) -> String:
    try:
        # Load the model and tokenizer
        var transformers = Python.import_module("transformers")
        var model_name = "gpt2"
        var tokenizer = transformers.GPT2Tokenizer.from_pretrained(model_name)
        var model = transformers.GPT2LMHeadModel.from_pretrained(model_name)

        var prompt: String = "The following is a conversation with an AI assistant. \n\nUser: " + user_message + "\nAI:"
        # Tokenize the input text
        var inputs = tokenizer(prompt, return_tensors="pt")
        # Set pad_token_id to eos_token_id to avoid unexpected behavior
        var pad_token_id = tokenizer.eos_token_id
        # Generate text using the model
        var outputs = model.generate(
            inputs.input_ids, 
            attention_mask=inputs.attention_mask,
            max_length=254,
            pad_token_id=pad_token_id,
        )

        # Decode the generated tokens into text
        var generated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
        
        # Extract the response part of the generated text
        var response = generated_text.split("AI:")[1].split("User:")[0].strip()
        return response
    except e:
        return (str(e) + "gpt2")


fn get_embedding(user_message: String) -> String:
    try:
        var openai = Python.import_module("openai")
        var os = Python.import_module("os")
        var dot_env = Python.import_module("dotenv")
        dot_env.load_dotenv()
        var api_key = os.getenv('OPENAI_KEY')
        var client = openai.OpenAI(api_key=api_key)
        var text = user_message.replace("\n", " ")
        return client.embeddings.create(input = text, model="text-embedding-3-small").data[0].embedding
    except e:
        return str(e)


fn main() raises:
    var message = argv()[1]
    var api_key = argv()[2]
    var response = generate_response(message, api_key)
    print(response)
    # var embedding = get_embedding(message)
    # print(embedding)