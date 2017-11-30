# Howdoi.el

Backend for the [Howdoi](https://github.com/gleitz/howdoi) command.

![Demonstration](https://raw.githubusercontent.com/galaunay/howdoi.el/master/doc/howdoi.gif)

## Install

howdoi.el requires Emacs-24.4 or later
and [Howdoi](https://github.com/gleitz/howdoi).

#### Installing howdoi

Install howdoi from your package manager or from
[the official website](https://github.com/gleitz/howdoi).

#### Installing howdoi.el from git

  1. Clone the howdoi repository:

```bash
    $ git clone https://github.com/galaunay/howdoi.el.git /path/to/howdoi/directory
```

  2. Add the following lines to `.emacs.el` (or equivalent):

```elisp
    (add-to-list 'load-path "/path/to/howdoi/directory")
    (require 'howdoi)
```

## Configuration

howdoi.el behaviour can be customized through the customization panel :

```elisp
(customize-group 'howdoi)
```

howdoi.el does not define default keybindings, so you may want to add
some :

```elisp
(define-key latex-mode-map (kbd "C-c h") 'howdoi)
```

or for Evil users:

```elisp
(evil-leader/set-key-for-mode 'latex-mode "h" 'howdoi)
```

## Basic usage

Just `M-x howdoi`, this will ask you for a query and display the answer in a new buffer.
In the howdoi buffer, you can use the following keys:

| Key   | Command                        | Effect                                            |
| :---: | :----------------------------- | :----------------------------------------------- |
|   n   | `howdoi-show-next-answer`      | Show next answer                                 |
|   p   | `howdoi-show-previous-answer`  | Show previous answer                             |
|   f   | `howdoi-toggle-full-question`  | Toggle the display of the full/partial question  |
|   y   | `howdoi-yank-code`             | Yank the code currently displayed                |
|   z   | `howdoi-goto-webpage`          | Visit the webpage giving the current advice      |

## Contributing

The project is hosted on [github](https://github.com/galaunay/howdoi.el).
You can report issues or make pull requests here.
