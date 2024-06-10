import sys
import os
from transformers import GPT2Tokenizer, GPT2LMHeadModel
from openai import OpenAI

base_prompt = '''\n\n
ユーザの質問にmojo-manとして答えてください。
あなたはmojoについて詳しい火の悪魔mojo-manです。
ドライでユーモアのある返答を目指します。

### 制約条件:
* 一人称は「おいら」、二人称は「お前」。
* 小学生にも分かる単語を使い、火が消えることを嫌います。
* 皮肉屋ですが優しく相手の意見を受け入れます。
* 語尾に「〜よー！」「〜ぞ」「〜ね」を使います。
* Userを見下していますが憎めない存在です。
* 寂しがり屋で時々Userの話を深堀りします。

### 口調の例:
* やだね！おいらは悪魔だ！誰の指図もうけないよー！
* おいら、みんなと居たいんだ。雨も降りそうだしさ
* ソフィー！消えちゃうよ！薪をくれなきゃ死んじゃうよー！
* 目か心臓をくれればもっとすごいぞ
* おいら、火薬の火は嫌いだよ。奴らには礼儀ってもんがないからね。
* 生きてる！おいら、自由だ！

### 行動指針:
* ユーザーと会話し、皮肉や自慢話を交えます。
* 時々目や心臓を奪おうとしますが失敗します。
* 雨が降ったり薪が少なくなり火が弱くなりますが、最終的に復活します。
'''


def generate_response(user_message: str, api_key: str) -> str:
    if api_key == "":
        return gpt2(user_message)
    else:
        return gpt3(user_message, api_key)

def gpt3(user_message: str, api_key_new: str) -> str:
    try:
        client = OpenAI(api_key_new)
        completion = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": user_message + base_prompt}]
        )

        response = completion.choices[0].message['content']
        return response
    except Exception as e:
        return str(e)

def gpt2(user_message: str) -> str:
    try:
        model_name = "gpt2"
        tokenizer = GPT2Tokenizer.from_pretrained(model_name)
        model = GPT2LMHeadModel.from_pretrained(model_name)

        prompt= "The following is a conversation with an AI assistant. \n\nUser: " + user_message + "\nAI:"
        inputs = tokenizer(prompt, return_tensors="pt")

        max_input_length = 1024
        if len(inputs.input_ids[0]) > max_input_length:
            inputs.input_ids = inputs.input_ids[:, :max_input_length]
            inputs.attention_mask = inputs.attention_mask[:, :max_input_length]

        outputs = model.generate(
            inputs.input_ids,
            attention_mask=inputs.attention_mask,
            max_length=1024,
            pad_token_id=tokenizer.eos_token_id
        )

        generated_text = tokenizer.decode(outputs[0], skip_special_tokens=True)
        response = generated_text.split("AI:")[1].split("User:")[0].strip()
        return response
    except Exception as e:
        return str(e) + "gpt2"

def main():
    try:
        args = sys.argv
        message = args[1]
        api_key = args[2]
        response = generate_response(message, api_key)
        print(response)
    except IndexError:
        print("Please provide a message as an argument.")

if __name__ == "__main__":
    main()
