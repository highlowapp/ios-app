const h1Block = (content, editable) => {
    return `
    <h1 contenteditable='${editable}'>
        ${content}
    </h1>
    `
}