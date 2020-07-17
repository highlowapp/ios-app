const blockTypes = {
    'h1': H1Block,
    'h2': H2Block,
    'p': PBlock,
    'img': ImgBlock,
    'quote': QuoteBlock
}

class BlockManager {
    constructor(editor) {
        this.editor = editor
        this.blockIds = {}
        this.isPremium = false
    }

    loadBlocks(arr, viewerMode) {
        this.editor.innerHTML = ''
        for (let i = 0; i < arr.length; i++) {
            const blockItem = arr[i]
            if (blockItem['editable'] === undefined || blockItem['editable'] === null) {
                blockItem['editable'] = true
            }
            let block = new blockTypes[ blockItem['type'] ](blockItem)
            this.blockIds[block.id] = block

            if (viewerMode) {
                block.viewerModeOn()
            }

            block.addTo(this.editor)
        }
    }

    getBlockById(id) {
        return this.blockIds[id]
    }

    getBlockBefore(id) {
        let index = -1
        for (let i = 0; i < this.editor.children.length; i++) {
            if (this.editor.children[i].classList.contains('block')) {
                if (this.editor.children[i].id === id) {
                    index = i
                    break
                }
            }
        }

        if (index > 0) {
            return this.blockIds[this.editor.children[index-1].id]
        }

        return this.blockIds[id]
    }

    addBlockAfter(newBlock, refEl) {
        if (!this.isPremium && (document.querySelectorAll('#editor .block').length >= 10 || (document.querySelectorAll('.block.img').length >= 2 && newBlock instanceof ImgBlock))) {
            if (window.webkit && window.webkit.messageHandlers) {
                window.webkit.messageHandlers.showPremium.postMessage('show_paywall')
            } else {
                /*Show premium screen on web version*/
            }
            return false
        } else {
            this.blockIds[newBlock.id] = newBlock
            newBlock.addAfter(this.editor, refEl)
            return newBlock
        }
    }

    exportJson() {
        let blocks = []
        
        for (let i = 0; i < this.editor.children.length; i++) {
            if (this.editor.children[i].classList.contains('block')) {
                blocks.push(this.editor.children[i].id)
            }
        }

        let blocksJson = []
        
        for (let i = 0; i < blocks.length; i++) {
            blocksJson.push( this.blockIds[ blocks[i] ].exportJson() )
        }

        return blocksJson
    }

    convertBlockTo(block, newBlockType) {
        const newBlock = new newBlockType(block.attributes)
        block.handOff(newBlock)
        return newBlock
    }

    updateBlock(blockId, data) {
        const block = this.blockIds[blockId]
        block.updateWith(data)
    }

    appendBlock(block) {
        if (!this.isPremium && (document.querySelectorAll('#editor .block').length >= 10 || (document.querySelectorAll('.block.img').length >= 2 && newBlock instanceof ImgBlock))) {
            if (window.webkit && window.webkit.messageHandlers) {
                window.webkit.messageHandlers.showPremium.postMessage('show_paywall')
            } else {
                /*Show premium screen on web version*/
            }
        } else {
            this.blockIds[block.id] = block
            block.addTo(this.editor)
        }
    }

    unlockPremium() {
        this.isPremium = true
    }
}