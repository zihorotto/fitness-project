from flask import Flask, request, jsonify
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer, pipeline
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

# Modell betöltése
model_id = "google/flan-t5-large"
tokenizer = AutoTokenizer.from_pretrained(model_id)
model = AutoModelForSeq2SeqLM.from_pretrained(model_id)
generator = pipeline("text2text-generation", model=model, tokenizer=tokenizer)

@app.route('/generate-wod', methods=['POST'])
def generate_wod():
    data = request.get_json()

    name = data.get('name')
    type_ = data.get('type', 'AMRAP')
    category = data.get('category', 'GENERAL')
    duration = data.get('durationInMinutes', 20)
    movements = data.get('movements')

    # Mozgáslista előkészítése
    movements_list = ', '.join([m.strip() for m in movements.split(',')]) if movements else None
    movements_text = (
        f"Use only these movements: {movements_list}."
        if movements_list else
        "Use a variety of functional movements appropriate to this workout style."
    )

    prompt = (
        f"You are a certified CrossFit coach.\n"
        f"Create a workout titled: **{name}**.\n"
        f"Design a {duration}-minute '{type_}' workout focused on '{category}' fitness.\n"
        f"{movements_text}\n"
        f"\n"
        f"The output must be structured exactly as described below:\n"
        f"- Start with one sentence summarizing the purpose, intensity, and focus of the workout.\n"
        f"- Then, write a numbered list of 3 to 6 exercises, using only the allowed movements.\n"
        f"- For each exercise, include:\n"
        f"  • The name of the movement\n"
        f"  • The number of reps or the duration (e.g., 15 reps, 30 seconds)\n"
        f"  • A short explanation about the purpose or correct technique of the movement.\n"
        f"- After the list, add 2–3 sentences of general coaching advice, including:\n"
        f"  • pacing or target intensity\n"
        f"  • recommended rest (if any)\n"
        f"  • scaling options\n"
        f"  • and any safety/performance tips.\n"
        f"Do not repeat these instructions. Only generate the workout content.\n"
    )

    result = generator(prompt, max_new_tokens=512)[0]['generated_text']
    full_text = result.strip()

    return jsonify({
        "name": name,
        "type": type_,
        "category": category,
        "durationInMinutes": duration,
        "movements": movements,
        "description": full_text.split('\n')[0],
        "fullDescription": full_text
    })

if __name__ == '__main__':
    app.run(debug=True)
