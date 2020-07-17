let generateId = () => {
    let s4 = () => {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    //return id of format 'aaaaaaaa'-'aaaa'-'aaaa'-'aaaa'-'aaaaaaaaaaaa'
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
}


class Block {
    constructor(attributes) {
        this.id = generateId()
        this.editable = attributes['editable']
        this.attributes = attributes
        this.viewerMode = false
        this.createElement(attributes)
    }

    createElement(attributes) {
        this.el = document.createElement('div')
    }

    getElement() {
        return this.el
    }

    addTo(editor) {
        const block = this.prepareBlock()
        editor.appendChild(block)
    }

    addAfter(editor, block) {
        const newBlock = this.prepareBlock()
        editor.insertBefore(newBlock, block.nextSibling)
    }

    viewerModeOn() {
        this.viewerMode = true
    }

    prepareBlock() {
        const block = document.createElement('div')
        block.id = this.id
        block.classList.add('block')
        block.classList.add(this.type)
        

        if (!this.viewerMode) {
            const dragger = document.createElement('div')
            dragger.classList.add('material-icons')
            dragger.classList.add('blockHandle')
            if (this.editable) {
                dragger.innerHTML = 'drag_handle'
            } else {
                dragger.innerHTML = 'lock'
                dragger.classList.add('locked')
            }
            block.appendChild(dragger)
        }
        block.appendChild(this.el)
        return block
    }

    handOff(block) {
        block.id = this.id
        block.attributes = this.attributes
        block.editable = this.editable
    }

    exportJson() {
        return {}
    }

    updateWith(data) {

    }
}

class H1Block extends Block {
    constructor(content) {
        super(content)
        this.type = 'h1'
    }

    createElement(attributes) {
        this.el = document.createElement('h1')
        this.el.contentEditable = this.editable
        if ('content' in attributes) {
            this.el.innerHTML = attributes['content']
        }
    }

    exportJson() {
        return {
            type: this.type,
            content: this.el.innerHTML,
            editable: this.editable
        }
    }
}

class H2Block extends Block {
    constructor(content) {
        super(content)
        this.type = 'h2'
    }

    createElement(attributes) {
        this.el = document.createElement('h2')
        this.el.contentEditable = this.editable
        if ('content' in attributes) {
            this.el.innerHTML = attributes['content']
        }
    }

    exportJson() {
        return {
            type: this.type,
            content: this.el.innerHTML,
            editable: this.editable
        }
    }
}

class PBlock extends Block {
    constructor(content) {
        super(content)
        this.type = 'p'
    }

    createElement(attributes) {
        this.el = document.createElement('p')
        this.el.contentEditable = this.editable
        if ('content' in attributes) {
            this.el.innerHTML = attributes['content']
        }
    }

    exportJson() {
        return {
            type: this.type,
            content: this.el.innerHTML,
            editable: this.editable
        }
    }
}

class ImgBlock extends Block {
    constructor(content) {
        super(content)
        this.type = 'img'
    }

    createElement(attributes) {
        this.el = document.createElement('div')
        this.el.placeholder = document.createElement('div')
        this.el.style.width = '85%'
        this.el.appendChild(this.el.placeholder)
        
        const addIcon = document.createElement('i')
        addIcon.style.color = 'gray'
        addIcon.classList.add('material-icons')
        addIcon.innerHTML = 'add_photo_alternate'

        this.el.placeholder.classList.add('img-placeholder')
        this.el.placeholder.appendChild(addIcon)
        this.el.placeholder.addIcon = addIcon

        this.el.img = document.createElement('img')
        this.el.appendChild(this.el.img)
        this.el.img.style.display = 'none'

        this.el.placeholder.addEventListener('click', (event) => {
            if (window.webkit && window.webkit.messageHandlers) {
                window.webkit.messageHandlers.chooseImage.postMessage({
                    'blockId': this.id
                })
            } else {
                const url = prompt('Enter URL:')
                if (url != undefined && url != null && url != '') {
                    this.setLink(url)
                }
            }
        })

        this.el.img.addEventListener('click', (event) => {
            if (window.webkit && window.webkit.messageHandlers) {
                window.webkit.messageHandlers.chooseImage.postMessage({
                    'blockId': this.id
                })
            } else {
                const url = prompt('Enter URL:')
                if (url != undefined && url != null && url != '') {
                    this.setLink(url)
                }
            }
        })

        this.el.contentEditable = false
        if ('src' in attributes && attributes['src'] != '') {
            this.setLink(attributes['src'])
        }
    }

    setLink(url) {
        this.el.img.src = url
        this.el.placeholder.style.display = 'none'
        this.el.img.style.display = 'block'
    }

    startLoading() {
        this.el.placeholder.addIcon.innerHTML = 'hourglass_top'
        this.el.placeholder.addIcon.classList.add('loading')
    }
    stopLoading() {
        this.el.placeholder.addIcon.innerHTML = 'add_photo_alternate'
        this.el.placeholder.addIcon.classList.remove('loading')
    }


    exportJson() {
        return {
            type: this.type,
            src: this.el.img.src,
            editable: this.editable
        }
    }

    updateWith(data) {
        if ('url' in data) {
            console.log(data['url'])
            this.setLink(data['url'])
        }
    }
}

class QuoteBlock extends Block {
    constructor(content) {
        super(content)
        this.type = 'quote'
    }

    createElement(attributes) {
        this.el = document.createElement('blockquote')
        this.el.contentEditable = this.editable
        if ('content' in attributes) {
            this.el.innerHTML = attributes['content']
        }
    }

    exportJson() {
        return {
            type: this.type,
            content: this.el.innerHTML,
            editable: this.editable
        }
    }
}