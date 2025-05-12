export const FeatureCard = ({ title, text, src, alt }) => {
    return (
        <>
            <div className="col-md-3 d-flex flex-column align-items-center text-center">
                <img
                    src={src}
                    alt={alt}
                    style={{ maxHeight: "200px", width: "auto", margin: "2em 0" }}
                />
                <h4 className="text-feature">{title}</h4>
                <p className="text-feature">{text}</p>
            </div>
        </>
    )
}
